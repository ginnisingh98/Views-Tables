--------------------------------------------------------
--  DDL for Package Body GMD_LCF_FETCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_LCF_FETCH_PKG" AS
/* $Header: GMDLCFMB.pls 120.15 2006/10/11 19:20:33 rajreddy noship $ */

    /*##############################################################
  # NAME
  #	calculate
  # SYNOPSIS
  #	proc   calculate
  # DESCRIPTION
  #      This procedure calculates the values for the products
  #      by performing the rollups based on data type.
  ###############################################################*/

  PROCEDURE calculate (V_formulation_spec_id IN NUMBER, V_line_id IN NUMBER,
  		       X_return_status  OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_prod IS
      SELECT a.tech_parm_name,a.lm_unit_code,b.tech_parm_id,a.data_type
      FROM   gmd_tech_parameters_b a, gmd_technical_reqs b
      WHERE  a.tech_parm_id = b.tech_parm_id
      AND    b.formulation_spec_id = V_formulation_spec_id
      AND    a.data_type IN (5,6,12)
      UNION
      SELECT a.tech_parm_name,a.lm_unit_code,b.tech_parm_id,a.data_type
      FROM   gmd_tech_parameters_b a, gmd_formulation_specs b
      WHERE  a.tech_parm_id = b.tech_parm_id
      AND    b.formulation_spec_id = V_formulation_spec_id
      AND    a.data_type IN (5,6,12);

  BEGIN
    FOR l_rec IN Cur_get_prod LOOP
      FND_MSG_PUB.INITIALIZE;
      IF (l_rec.data_type = 5 OR l_rec.data_type = 12) THEN
        rollup_wt_pct (V_parm_name	=> l_rec.tech_parm_name,
                       V_parm_id	=> l_rec.tech_parm_id,
                       V_line_id        => V_line_id,
                       X_return_status	=> X_return_status);
      ELSIF l_rec.data_type = 6 THEN
        rollup_vol_pct (V_parm_name	=> l_rec.tech_parm_name,
                        V_parm_id	=> l_rec.tech_parm_id,
                        V_line_id        => V_line_id,
                        X_return_status	=> X_return_status);
      END IF;
    END LOOP;
  END calculate;

  /*##############################################################
  # NAME
  #	rollup_wt_pct
  # SYNOPSIS
  #	proc   rollup_wt_pct
  # DESCRIPTION
  #      This procedure gets the values for the products for the
  #      by performing the weight rollup.
  ###############################################################*/

  PROCEDURE rollup_wt_pct (V_parm_name 		IN		VARCHAR2,
  			   V_line_id 		IN 		NUMBER,
                           V_parm_id		IN		NUMBER,
                           X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_get_line_ingred IS
      SELECT NVL(SUM(weight), 0), NVL(SUM(weightpct), 0)
      FROM
       (SELECT qty_mass weight, qty_mass * value weightpct
        FROM   gmd_lcf_details_gtmp d, gmd_lcf_tech_data_gtmp t
        WHERE  d.line_id = t.line_id (+)
        AND    t.tech_parm_id (+) = V_parm_id
        AND    line_type = -1);

    X_ingred_wt	  	NUMBER;
    X_ingred_wtpct	NUMBER;
    X_rollup		NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    OPEN Cur_get_line_ingred;
    FETCH Cur_get_line_ingred INTO X_ingred_wt, X_ingred_wtpct;
    CLOSE Cur_get_line_ingred;

    IF (NVL(X_ingred_wt,0)) <> 0 THEN
      X_rollup := (NVL(X_ingred_wtpct,0)) / (NVL(X_ingred_wt,0));
    END IF;

    UPDATE gmd_lcf_tech_data_gtmp
    SET    value = X_rollup
    WHERE  tech_parm_id = V_parm_id
    AND    line_id      = V_line_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_LCF_TECH_DATA_GTMP
               (TECH_PARM_ID,
		VALUE,
		NUM_DATA,
		LINE_ID)
          VALUES
	       (V_parm_id,
	        X_rollup,
	        X_rollup,
	        V_line_id);
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_WEIGHT_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Rollup_Wt_Pct');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END rollup_wt_pct;

  /*##############################################################
  # NAME
  #	rollup_vol_pct
  # SYNOPSIS
  #	proc   rollup_vol_pct
  # DESCRIPTION
  #      This procedure gets the values for the products for the
  #      by performing the voulme rollup.
  ###############################################################*/

  PROCEDURE rollup_vol_pct (V_parm_name 	IN		VARCHAR2,
    			    V_line_id 		IN 		NUMBER,
                            V_parm_id		IN		NUMBER,
                            X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_get_line_ing  IS
      SELECT SUM(volume), SUM(volumepct)
      FROM
       (SELECT qty_vol volume, qty_vol * value volumepct
        FROM   gmd_lcf_details_gtmp d, gmd_lcf_tech_data_gtmp t
        WHERE  d.line_id = t.line_id (+)
        AND    t.tech_parm_id (+) = V_parm_id
        AND    line_type = -1);

    X_ingred_vol  	NUMBER;
    X_ingred_volpct	NUMBER;
    X_rollup		NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    OPEN Cur_get_line_ing;
    FETCH Cur_get_line_ing INTO X_ingred_vol, X_ingred_volpct;
    CLOSE Cur_get_line_ing;

    IF (NVL(X_ingred_vol,0)) <> 0 THEN
      X_rollup := (NVL(X_ingred_volpct,0)) / (NVL(X_ingred_vol,0));
    END IF;

    UPDATE gmd_lcf_tech_data_gtmp
    SET    value = X_rollup
    WHERE  tech_parm_id = V_parm_id
    AND    line_id      = V_line_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_LCF_TECH_DATA_GTMP
               (TECH_PARM_ID,
  		NUM_DATA,
		VALUE,
		LINE_ID)
          VALUES
	       (V_parm_id,
                X_rollup,
	        X_rollup,
	        V_line_id);
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_WEIGHT_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Rollup_Vol_Pct');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END rollup_vol_pct;

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
      FROM   gmd_lcf_tech_data_gtmp
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

  PROCEDURE update_line_mass_vol_qty (V_orgn_id  		IN	NUMBER,
                                      V_line_id			IN	NUMBER,
                                      V_density_parameter	IN	VARCHAR2,
                                      V_mass_uom		IN	VARCHAR2,
                                      V_vol_uom			IN	VARCHAR2,
                                      X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_line_qty IS
      SELECT inventory_item_id, lot_number, qty,
             detail_uom,primary_uom,secondary_uom
      FROM   gmd_lcf_details_gtmp
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
    l_error		NUMBER := 0;
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
                                              		     plot_number => NULL,
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
                                              		    plot_number => NULL,
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
                                              		        plot_number => NULL,
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

    UPDATE gmd_lcf_details_gtmp
    SET qty_mass    = l_mass_qty,
        mass_uom    = V_mass_uom,
        qty_vol     = l_vol_qty,
        vol_uom     = V_vol_uom,
        primary_qty = l_primary_qty,
        primary_uom = l_rec.primary_uom
    WHERE line_id = V_line_id;

    OPEN Cur_line_item_number(l_rec.inventory_item_id);
    FETCH Cur_line_item_number INTO l_item_no;
    CLOSE Cur_line_item_number;

    IF l_error = 1 THEN
      X_return_status := FND_API.g_ret_sts_error;
      gmd_api_grp.log_message('LM_BAD_UOMCV', 'ITEM_NO',l_item_no);
    END IF;

  EXCEPTION
    WHEN line_not_found THEN
      X_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Update_Line_Mass_Vol_Qty');
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
      FROM   gmd_lcf_details_gtmp
      WHERE  line_type <> 1;

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
      IF l_return_status <> x_return_status THEN
        X_return_status := l_return_status;
      END IF;
    END LOOP;
  END update_mass_vol_qty;

  /*##############################################################
  # NAME
  #	load_cost_values
  # SYNOPSIS
  #	proc   load_cost_values
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_cost_values (V_orgn_id IN NUMBER, V_inv_item_id IN NUMBER, V_cost_type IN VARCHAR2,
                              V_date IN DATE, V_cost_orgn IN VARCHAR2, V_source IN NUMBER, X_value OUT NOCOPY NUMBER) IS
    l_msg_data		VARCHAR2(2000);
    l_msg_count		NUMBER;
    l_total_cost	NUMBER;
    l_cost_type		VARCHAR2(80);
    l_no_rows		NUMBER;
    l_cost		NUMBER;
    l_qty		NUMBER;
    l_component		NUMBER;
    l_analy_code	VARCHAR2(70);
    l_return_status	VARCHAR2(1);
  BEGIN
    --Insert the optimize parameter values defined in the formulation specification screen.
    --Get the costing source organization.
    l_cost_type := V_cost_type;

    IF (V_source = 1) THEN
      --Call the Process cost api to get the values.
      l_qty := gmf_cmcommon.get_process_item_cost (p_api_version 	     => 1.0
   	 			    	         , p_init_msg_list 	     => 'F'
                                                 , x_return_status 	     => l_return_status
                                                 , x_msg_count               => l_msg_count
                                                 , x_msg_data      	     => l_msg_data
                                                 , p_inventory_item_id       => V_inv_item_id
                                                 , p_organization_id         => V_cost_orgn
                                                 , p_transaction_date        => V_date
                                                 , p_detail_flag             => 1
                                                 , p_cost_method             => l_cost_type
                                                 , p_cost_component_class_id => l_component
                                                 , p_cost_analysis_code      => l_analy_code
                                                 , x_total_cost              => l_total_cost
                                                 , x_no_of_rows              => l_no_rows);

      IF (l_qty > 0) THEN
        X_value := l_total_cost;
      END IF;
    ELSE
      --Call the External cost api to get the values.
      l_cost := gmd_lcf_util.get_cost (p_item_id 	 => V_inv_item_id
	  			      ,p_organization_id => V_orgn_id
				      ,p_cost_orgn_id    => V_cost_orgn
				      ,p_lot_no          => NULL
				      ,p_qty	         => NULL
				      ,p_uom	         => NULL
				      ,p_cost_date       => V_date);
      IF (l_cost >= 0) THEN
        X_value := l_cost;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Load_cost_Values');
  END load_cost_values;

  /*##############################################################
  # NAME
  #	load_tech_values
  # SYNOPSIS
  #	proc   load_tech_values
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_tech_values (V_orgn_id IN NUMBER, V_formulation_spec_id IN NUMBER, V_date IN DATE) IS
    CURSOR Cur_get_type IS
      SELECT a.*, b.line_id, b.tech_parm_id tech, c.inventory_item_id
      FROM   gmd_tech_parameters_b a, gmd_lcf_tech_data_gtmp b, gmd_lcf_details_gtmp c
      WHERE  a.tech_parm_id = b.tech_parm_id
      AND    b.line_id = c.line_id;

    CURSOR Cur_get_value (V_inventory_item_id NUMBER, V_tech_parm_id NUMBER) IS
      SELECT a.num_data
      FROM   gmd_technical_data_vl a, gmd_lcf_tech_data_gtmp b, gmd_lcf_details_gtmp c
      WHERE  a.tech_parm_id = b.tech_parm_id
      AND    a.tech_parm_id = V_tech_parm_id
      AND    a.inventory_item_id = c.inventory_item_id
      AND    a.inventory_item_id = V_inventory_item_id
      AND    a.organization_id   = V_orgn_id;

    CURSOR Cur_get_cost_method (P_orgn_id NUMBER) IS
      SELECT Cost_Type, cost_source
      FROM   gmd_tech_parameters_b
      WHERE  organization_id = P_orgn_id
      AND    Default_cost_parameter = 1;

    l_density_parameter	VARCHAR2(240);
    l_value		NUMBER;
    X_value		NUMBER;
    l_parm_value	VARCHAR2(240);
    l_return_status	VARCHAR2(1);
    l_cost_type		VARCHAR2(4);
    l_cost_source	NUMBER;
  BEGIN
    l_density_parameter := FND_PROFILE.VALUE('LM$DENSITY');
    /* Inserting the technical parameter data  of item and lot to temp tables*/
    IF (V_orgn_id IS NOT NULL) THEN
      INSERT INTO GMD_LCF_TECH_DATA_GTMP
               (LINE_ID,TECH_PARM_ID,TECH_PARM_NAME,QCASSY_TYP_ID)
		SELECT c.line_id,b.tech_parm_id,d.tech_parm_name,d.qcassy_typ_id
		FROM   gmd_technical_reqs b,gmd_lcf_details_gtmp c, gmd_tech_parameters_b d
		WHERE  b.tech_parm_id = d.tech_parm_id
		       AND b.formulation_spec_id = V_formulation_spec_id;

      -- if tech params data type is not 12 then insert the values from item tech data tables
      -- at once no need to loop through.
      INSERT INTO GMD_LCF_TECH_DATA_GTMP
               (LINE_ID,TECH_PARM_ID,TECH_PARM_NAME,QCASSY_TYP_ID)
		SELECT c.line_id,b.tech_parm_id,b.tech_parm_name,b.qcassy_typ_id
		FROM   gmd_tech_parameters_b b, gmd_lcf_details_gtmp c,
		       gmd_formulation_specs e
		WHERE  b.tech_parm_id = e.tech_parm_id
		       AND e.formulation_spec_id = V_formulation_spec_id;

      gmd_api_grp.fetch_parm_values (P_orgn_id       => V_orgn_id
                                    ,P_parm_name     => 'GMD_COST_SOURCE_ORGN'
                                    ,P_parm_value    => l_parm_value
                                    ,X_return_status => l_return_status);

      -- Get cost type and cost source in cost source orgn
      IF l_parm_value IS NOT NULL THEN
        OPEN Cur_get_cost_method(l_parm_value);
        FETCH Cur_get_cost_method INTO l_cost_type, l_cost_source;
        CLOSE Cur_get_cost_method;
      END IF;

      IF l_cost_type IS NOT NULL THEN
        OPEN Cur_get_cost_method(V_orgn_id);
        FETCH Cur_get_cost_method INTO l_cost_type, l_cost_source;
        CLOSE Cur_get_cost_method;
      END IF;

      FOR l_rec IN Cur_get_type LOOP
        IF l_rec.data_type = 12 THEN
          load_cost_values (V_orgn_id      => V_orgn_id,
                            V_inv_item_id  => l_rec.inventory_item_id,
                            V_cost_type    => NVL(l_rec.cost_type,l_cost_type),
                            V_date         => V_date,
                            V_cost_orgn    => NVL(l_parm_value,V_orgn_id),
                            V_source       => NVL(l_rec.cost_source, l_cost_source),
                            X_value        => l_value);
          UPDATE GMD_LCF_TECH_DATA_GTMP
          SET    value = l_value,
                 num_data = l_value
          WHERE  tech_parm_id = l_rec.tech
          AND    line_id = l_rec.line_id;
        ELSIF l_rec.qcassy_typ_id IS NOT NULL THEN
          load_quality_data (V_line_id       => l_rec.line_id,
                             V_orgn_id       => V_orgn_id,
                             V_qcassy_typ_id => l_rec.qcassy_typ_id,
                             V_tech_parm_id  => l_rec.tech);
        ELSE
          OPEN Cur_get_value (l_rec.inventory_item_id,l_rec.tech);
          FETCH Cur_get_value INTO X_value;
          CLOSE Cur_get_value;
          UPDATE GMD_LCF_TECH_DATA_GTMP
          SET    value = X_value,
                 num_data = X_value
          WHERE  tech_parm_id = l_rec.tech
          AND    line_id = l_rec.line_id;
        END IF;
      END LOOP;

      --A Row will be inserted for density parameter and this will be used for
      --Product rollup calculations.
      INSERT INTO GMD_LCF_TECH_DATA_GTMP
               (LINE_ID,TECH_PARM_ID,TECH_PARM_NAME,VALUE,NUM_DATA,QCASSY_TYP_ID)
		SELECT c.line_id,a.tech_parm_id,d.tech_parm_name,
		       a.num_data,a.num_data,d.qcassy_typ_id
		FROM   gmd_technical_data_vl a,
		       gmd_lcf_details_gtmp c, gmd_tech_parameters_b d
		WHERE  a.tech_parm_id = d.tech_parm_id
		       AND d.tech_parm_name = l_density_parameter
		       AND a.organization_id = V_orgn_id
		       AND a.inventory_item_id = c.inventory_item_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Load_Tech_Values');
  END load_tech_values;

  /*##############################################################
  # NAME
  #	load_items
  # SYNOPSIS
  #	proc   load_items
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_items (V_formulation_spec_id IN NUMBER, V_organization_id IN NUMBER,V_ingred_pick_base IN VARCHAR2,
  			V_formula_no IN VARCHAR2, V_batch_no IN VARCHAR2,V_date IN DATE) IS
    CURSOR Cur_get_sim_material IS
      SELECT a.*, b.concatenated_segments item
      FROM   gmd_material_details_gtmp a, mtl_system_items_kfv b
      WHERE  line_type = -1
      AND    a.inventory_item_id = b.inventory_item_id
      AND    b.organization_id = V_organization_id;

    CURSOR Cur_get_spec IS
      SELECT std_uom
      FROM   gmd_formulation_specs
      WHERE  formulation_spec_id = V_formulation_spec_id;

    CURSOR Cur_get_formula IS
      SELECT a.*, b.concatenated_segments, b.description, b.primary_uom_code
      FROM   gmd_material_reqs a, mtl_system_items_kfv b
      WHERE  formulation_spec_id = V_formulation_spec_id
             AND a.inventory_item_id = b.inventory_item_id
             AND b.organization_id = V_organization_id
      ORDER BY b.concatenated_segments;

    CURSOR Cur_get_comp IS
      SELECT b.concatenated_segments, b.inventory_item_id,
             b.description, b.primary_uom_code
      FROM   mtl_system_items_kfv b
      WHERE  EXISTS (SELECT 1
                     FROM   gmd_lcf_category_hdr_gtmp a, mtl_item_categories c
                     WHERE  a.category_set_id = c.category_set_id
                            AND a.category_id = c.category_id
                            AND b.organization_id = c.organization_id
                            AND c.organization_id = V_organization_id
                            AND b.inventory_item_id = c.inventory_item_id)
      ORDER BY b.concatenated_segments;

    CURSOR Cur_density (V_inv_item_id NUMBER,V_density_parameter VARCHAR2) IS
      SELECT num_data
      FROM   gmd_technical_data_vl
      WHERE  organization_id = V_organization_id
      AND    inventory_item_id = V_inv_item_id
      AND    tech_parm_name = V_density_parameter;

    l_value		NUMBER;
    l_line_id		NUMBER DEFAULT 0;
    l_line_no		NUMBER DEFAULT 0;
    l_new_qty		NUMBER;
    l_std_uom		VARCHAR2(3);
    X_return_status	VARCHAR2(1);
    l_density		VARCHAR2(32);

    l_formula_rec	Cur_get_formula%ROWTYPE;
    l_simulation_rec	Cur_get_sim_material%ROWTYPE;
    l_comp_rec		Cur_get_comp%ROWTYPE;
  BEGIN
    l_density := FND_PROFILE.VALUE ('LM$DENSITY');
    --Get the product uom
    OPEN Cur_get_spec;
    FETCH Cur_get_spec INTO l_std_uom;
    CLOSE Cur_get_spec;
    IF (V_batch_no IS NOT NULL OR V_formula_no IS NOT NULL) THEN
      --if batch or formula number is passed then load the ingredients from simulator temp tables.
      OPEN Cur_get_sim_material;
      LOOP
      FETCH Cur_get_sim_material INTO l_simulation_rec;
      EXIT WHEN Cur_get_sim_material%NOTFOUND;
      --Call the uom routine to convert item's primary uom from product uom
      --defined in formulation specification screen.
      OPEN Cur_density (l_simulation_rec.inventory_item_id, l_density);
      FETCH Cur_density INTO l_value;
      CLOSE Cur_density;
      l_new_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_simulation_rec.inventory_item_id,
                                                            pformula_id => NULL,
                                              		    plot_number => NULL,
                                                            pcur_qty    => 1,
                                                            pcur_uom    => l_simulation_rec.detail_uom,
                                                            pnew_uom    => l_std_uom,
                                                            patomic	=> 0,
                                                            plab_id	=> V_organization_id,
                                                            pcnv_factor => l_value);
          IF (l_new_qty = -99999) THEN
            X_return_status := FND_API.g_ret_sts_error;
            gmd_api_grp.log_message('IC_API_UOM_CONVERSION_ERROR', 'ITEM_NO',l_simulation_rec.item,
                                    'FROM_UOM',l_simulation_rec.detail_uom,'TO_UOM',l_std_uom );
          END IF;
          INSERT INTO GMD_LCF_DETAILS_GTMP
            (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,INVENTORY_ITEM_ID,CONCATENATED_SEGMENTS,
             CONV_FACTOR,DESCRIPTION,DETAIL_UOM,PRIMARY_UOM,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE)
          VALUES
            (1,l_simulation_rec.line_id,l_simulation_rec.line_type,l_simulation_rec.line_no,0,
             l_simulation_rec.inventory_item_id,l_simulation_rec.item,l_new_qty,
             l_simulation_rec.description,l_simulation_rec.detail_uom,l_simulation_rec.detail_uom,
             l_simulation_rec.created_by,l_simulation_rec.creation_date,
             l_simulation_rec.last_updated_by,l_simulation_rec.last_update_date);
             gmd_lcf_fetch_pkg.get_category_value (V_inventory_item_id => l_simulation_rec.inventory_item_id,
                                                   V_organization_id   => V_organization_id,
                                                   V_line_id           => l_simulation_rec.line_id);
      END LOOP;
      CLOSE Cur_get_sim_material;
    ELSE
      IF (V_formulation_spec_id IS NOT NULL) THEN
        IF (V_ingred_pick_base = 'MAT') THEN
          OPEN Cur_get_formula;
          LOOP
            l_line_id := l_line_id + 1;
          FETCH Cur_get_formula INTO l_formula_rec;
          EXIT WHEN Cur_get_formula%NOTFOUND;
          --Call the uom routine to convert item's primary uom from product uom
          --defined in formulation specification screen.
          OPEN Cur_density (l_formula_rec.inventory_item_id, l_density);
          FETCH Cur_density INTO l_value;
          CLOSE Cur_density;
          l_new_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_formula_rec.inventory_item_id,
                                                                pformula_id => NULL,
                                                		plot_number => NULL,
                                                                pcur_qty    => 1,
                                                                pcur_uom    => l_formula_rec.primary_uom_code,
                                                                pnew_uom    => l_std_uom,
                                                                patomic	    => 0,
                                                                plab_id	    => V_organization_id,
                                                                pcnv_factor => l_value);
          IF (l_new_qty = -99999) THEN
            X_return_status := FND_API.g_ret_sts_error;
            gmd_api_grp.log_message('IC_API_UOM_CONVERSION_ERROR', 'ITEM_NO',l_formula_rec.concatenated_segments,
                                    'FROM_UOM',l_formula_rec.primary_uom_code,'TO_UOM',l_std_uom );
          END IF;
          INSERT INTO GMD_LCF_DETAILS_GTMP
            (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,INVENTORY_ITEM_ID,CONCATENATED_SEGMENTS,
             CONV_FACTOR,DESCRIPTION,DETAIL_UOM,PRIMARY_UOM,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE)
          VALUES
            (1,l_line_id,-1,l_formula_rec.line_no,0,l_formula_rec.inventory_item_id,l_formula_rec.concatenated_segments,
             l_new_qty,l_formula_rec.description,l_formula_rec.primary_uom_code,l_formula_rec.primary_uom_code,
             l_formula_rec.created_by,l_formula_rec.creation_date,
             l_formula_rec.last_updated_by,l_formula_rec.last_update_date);
             gmd_lcf_fetch_pkg.get_category_value (V_inventory_item_id => l_formula_rec.inventory_item_id,
                                                   V_organization_id   => V_organization_id,
                                                   V_line_id           => l_line_id);
          END LOOP;
          CLOSE Cur_get_formula;
        ELSE
          OPEN Cur_get_comp;
          LOOP
            l_line_id := l_line_id + 1;
            l_line_no := l_line_no + 1;
          FETCH Cur_get_comp INTO l_comp_rec;
          EXIT WHEN Cur_get_comp%NOTFOUND;
          --Call the uom routine to convert item's primary uom from product uom
          --defined in formulation specification screen.
          OPEN Cur_density (l_comp_rec.inventory_item_id, l_density);
          FETCH Cur_density INTO l_value;
          CLOSE Cur_density;
          l_new_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_comp_rec.inventory_item_id,
                                                                pformula_id => NULL,
                                                		plot_number => NULL,
                                                                pcur_qty    => 1,
                                                                pcur_uom    => l_comp_rec.primary_uom_code,
                                                                pnew_uom    => l_std_uom,
                                                                patomic	    => 0,
                                                                plab_id	    => V_organization_id,
                                                                pcnv_factor => l_value);
          IF (l_new_qty = -99999) THEN
            X_return_status := FND_API.g_ret_sts_error;
            gmd_api_grp.log_message('IC_API_UOM_CONVERSION_ERROR', 'ITEM_NO',l_comp_rec.concatenated_segments,
                                    'FROM_UOM',l_comp_rec.primary_uom_code,'TO_UOM',l_std_uom );
          END IF;

          INSERT INTO GMD_LCF_DETAILS_GTMP
            (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,ROLLUP_IND,INVENTORY_ITEM_ID,CONCATENATED_SEGMENTS,
             CONV_FACTOR,DESCRIPTION,DETAIL_UOM,PRIMARY_UOM)
          VALUES
            (1,l_line_id,-1,l_line_no,0,l_comp_rec.inventory_item_id,l_comp_rec.concatenated_segments,
             l_new_qty,l_comp_rec.description,l_comp_rec.primary_uom_code,l_comp_rec.primary_uom_code);

             gmd_lcf_fetch_pkg.get_category_value (V_inventory_item_id => l_comp_rec.inventory_item_id,
                                                   V_organization_id   => V_organization_id,
                                                   V_line_id           => l_line_id);
          END LOOP;
          CLOSE Cur_get_comp;
        END IF;
      END IF;
    END IF;
    --Call to load the item technical data.
    gmd_lcf_fetch_pkg.load_tech_values (V_orgn_id => V_organization_id,
     					V_formulation_spec_id => V_formulation_spec_id,
     					V_date		      => V_date);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Load_items');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END load_items;

  /*##############################################################
  # NAME
  #	load_categories
  # SYNOPSIS
  #	proc   load_categories
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_categories (V_formulation_spec_id IN NUMBER) IS
  BEGIN
    IF (V_formulation_spec_id IS NOT NULL) THEN
      INSERT INTO GMD_LCF_CATEGORY_HDR_GTMP
        (CATEGORY_ID,CATEGORY_NAME,CATEGORY_SET_ID,
         CATEGORY_SET_NAME,MIN_PCT,MAX_PCT)
      SELECT gcr.category_id,mc.concatenated_segments,
             gcr.category_set_id,mcs.category_set_name,
             gcr.min_pct,gcr.max_pct
      FROM   mtl_category_sets mcs, mtl_categories_kfv mc, gmd_compositional_reqs gcr
      WHERE  mcs.category_set_id = gcr.category_set_id
      AND    mc.category_id  = gcr.category_id
      AND    gcr.formulation_spec_id = V_formulation_spec_id
      ORDER BY order_no;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Load_Categories');
  END load_categories;

  /*##############################################################
  # NAME
  #	proc get_category_value
  # SYNOPSIS
  #	proc get_category_value
  # DESCRIPTION
  #      This procedure will see that a particular item is in category
  #      and based on that insert the date into temp table.
  ###############################################################*/

  PROCEDURE get_category_value (V_inventory_item_id IN NUMBER, V_organization_id IN NUMBER,
                                V_line_id IN NUMBER) IS
    CURSOR Cur_check_hdr_category IS
      SELECT category_id
      FROM   gmd_lcf_category_hdr_gtmp;

    CURSOR Cur_check_item_category (V_category_id NUMBER) IS
      SELECT 1
      FROM   mtl_item_categories
      WHERE  category_id = V_category_id
             AND inventory_item_id   = V_inventory_item_id
             AND organization_id = V_organization_id;

    l_value_ind		NUMBER;
    l_category_id	NUMBER;
    l_line_id		NUMBER;
    l_temp		NUMBER;
  BEGIN
    FOR l_rec IN Cur_check_hdr_category LOOP
      OPEN Cur_check_item_category(l_rec.category_id);
      FETCH Cur_check_item_category INTO l_temp;
      IF (Cur_check_item_category%FOUND) THEN
        l_value_ind := 1;
      ELSE
        l_value_ind := 0;
      END IF;
      CLOSE Cur_check_item_category;
      INSERT INTO GMD_LCF_CATEGORY_DTL_GTMP (LINE_ID,VALUE_IND,CATEGORY_ID)
                                     VALUES (V_line_id,l_value_ind,l_rec.category_id);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Load_Category_Value');
  END get_category_value;

  /*##############################################################
  # NAME
  #	load_quality_data
  # SYNOPSIS
  #	proc   load_quality_data
  # DESCRIPTION
  #      This procedure inserts the data into temp tables from quality
  #      tables.
  ###############################################################*/

  PROCEDURE load_quality_data (V_line_id IN NUMBER, V_orgn_id IN NUMBER,
                               V_qcassy_typ_id IN NUMBER,V_tech_parm_id IN NUMBER) IS

    CURSOR Cur_get_data IS
      SELECT *
      FROM   gmd_lcf_details_gtmp
      WHERE  line_id = V_line_id;

    l_rec Cur_get_data%ROWTYPE;
    l_return_status VARCHAR2(1);
    x_return_status VARCHAR2(1);
    l_value         VARCHAR2(80);
    l_inv_inp_rec_type GMD_QUALITY_GRP.inv_inp_rec_type;
    l_inv_val_out_rec_type GMD_QUALITY_GRP.inv_val_out_rec_type;
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
    l_inv_inp_rec_type.plant_id          := NULL;
    l_inv_inp_rec_type.test_id := V_qcassy_typ_id;
    gmd_quality_grp.get_inv_test_value (P_inv_test_inp_rec => l_inv_inp_rec_type,
		            		x_inv_test_out_rec => l_inv_val_out_rec_type,
  					x_return_status    => l_return_status);
    l_value := l_inv_val_out_rec_type.entity_value;

    IF (l_value IS NOT NULL) THEN
        UPDATE gmd_lcf_tech_data_gtmp
        SET    value = l_inv_val_out_rec_type.entity_value,
               num_data = l_inv_val_out_rec_type.entity_value
        WHERE  line_id = V_line_id
               AND tech_parm_id = V_tech_parm_id;
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'load_quality_data');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      NULL;
  END load_quality_data;

  /*##############################################################
  # NAME
  #	generate_lcf_data
  # SYNOPSIS
  #	proc   generate_lcf_data
  # DESCRIPTION
  #      This procedure inserts the data into rows and columns then
  #      call the lcf engine.
  ###############################################################*/

  PROCEDURE  generate_lcf_data (V_formulation_spec_id IN NUMBER, V_organization_id IN NUMBER,
                                V_formula_no IN VARCHAR2, V_batch_no IN VARCHAR2,V_date IN DATE,
                                X_return_code OUT NOCOPY NUMBER) IS

    --Formulation specification details.
    CURSOR Cur_get_formulation IS
      SELECT *
      FROM   gmd_formulation_specs
      WHERE  formulation_spec_id = V_formulation_spec_id;

    --Line id to be used to identify the specific line id number so that
    --we can pass the value as 1 for that item and 0 to others.
    CURSOR Cur_get_lineid IS
      SELECT line_id, inventory_item_id, concatenated_segments, conv_factor
      FROM   gmd_lcf_details_gtmp
      ORDER BY line_id;

    --Get the total count of material rows.
    CURSOR Cur_get_line_count IS
      SELECT COUNT(*)
      FROM   gmd_lcf_details_gtmp;

    --Get the technical parameter values for the paramter defined in the
    --formulation specification screen as optimize function.
    CURSOR Cur_get_optprm_value (V_tech_parm_id NUMBER, V_line_id NUMBER) IS
      SELECT value
      FROM   gmd_lcf_tech_data_gtmp
      WHERE  tech_parm_id = V_tech_parm_id
             AND line_id  = V_line_id;

    --Get the material requirements defined for particular formulation specification.
    CURSOR Cur_get_matl_req IS
      SELECT a.inventory_item_id, a.min_qty, a.max_qty,
             a.item_uom, a.range_type, b.concatenated_segments
      FROM   gmd_material_reqs a, gmd_lcf_details_gtmp b
      WHERE  (a.min_qty IS NOT NULL OR a.max_qty IS NOT NULL)
             AND a.formulation_spec_id = V_formulation_spec_id
             AND a.inventory_item_id = b.inventory_item_id
      ORDER BY b.line_id;

    --Get the line id and other details for item id passed from
    --the above requirement cursor
    CURSOR Cur_get_matreq_line (V_inventory_item_id NUMBER) IS
      SELECT line_id, concatenated_segments, conv_factor
      FROM   gmd_lcf_details_gtmp
      WHERE  inventory_item_id = V_inventory_item_id
      ORDER BY line_id;

    --Get the compositional requirements defined for particular formulation specification.
    CURSOR Cur_get_comp_req (V_formulation_spec_id NUMBER) IS
      SELECT a.category_id, a.min_pct, a.max_pct, b.category_name
      FROM   gmd_compositional_reqs a, gmd_lcf_category_hdr_gtmp b
      WHERE  a.category_id = b.category_id
             AND (a.min_pct IS NOT NULL OR a.max_pct IS NOT NULL)
             AND a.formulation_spec_id = V_formulation_spec_id
      ORDER BY order_no;

    --Get the line id(number like 3 or 4 etc) for the category id passed from
    --the above requirement cursor
    CURSOR Cur_get_category (V_category_id NUMBER) IS
      SELECT line_id
      FROM   gmd_lcf_category_dtl_gtmp
      WHERE  category_id = V_category_id
             AND value_ind = 1;

    --Get the technical requirements defined for particular formulation specification.
    CURSOR Cur_get_tech_req (V_formulation_spec_id NUMBER) IS
      SELECT a.tech_parm_id,a.min_value, a.max_value, b.tech_parm_name
      FROM   gmd_technical_reqs a, gmd_tech_parameters_b b
      WHERE  a.tech_parm_id = b.tech_parm_id
             AND (a.min_value IS NOT NULL OR a.max_value IS NOT NULL)
             AND a.formulation_spec_id = V_formulation_spec_id;
     -- ORDER BY a.tech_parm_id;

    --Get the technical parameter value and line id and for the above tech parameters.
    CURSOR Cur_get_tech_value (V_tech_parm_id NUMBER) IS
      SELECT line_id,value
      FROM   gmd_lcf_tech_data_gtmp
      WHERE  tech_parm_id = V_tech_parm_id
      ORDER BY line_id;

    --Get the lineid from details table to update the qty in categories dtl table.
    CURSOR Cur_get_line_dtl (V_item VARCHAR2) IS
      SELECT line_id, inventory_item_id, detail_uom, conv_factor
      FROM   gmd_lcf_details_gtmp
      WHERE  concatenated_segments = V_item;

    CURSOR Cur_get_conv_factor (V_line_id NUMBER) IS
      SELECT conv_factor
      FROM   gmd_lcf_details_gtmp
      WHERE  line_id = V_line_id;

    l_new_qty		NUMBER;
    l_min_qty		NUMBER;
    l_max_qty		NUMBER;
    l_prod_qty		NUMBER;
    l_count		NUMBER;
    l_line_id		NUMBER;
    l_conv_factor	NUMBER;
    l_inv_item_id	NUMBER;
    l_dtl_lineid	NUMBER;
    j_return		NUMBER;
    l_detail_uom	VARCHAR2(3);
    x_return_status     VARCHAR2(1);

    l_line_row		NUMBER := 0;
    l_row		NUMBER := 1;
    l_rt_row		NUMBER := 1;
    i 			NUMBER := 0;

    l_formulation	Cur_get_formulation%ROWTYPE;
    l_lt_matrix		gmd_lcf_engine.matrix;
    l_rt_matrix		gmd_lcf_engine.char_matrix;
    l_var 		gmd_lcf_engine.char_row;
    l_solved_tab	gmd_lcf_engine.solved_tab;

    --Following are used to print the matrix data for debug.
    l_print_line	VARCHAR2(2000);
    l_value		NUMBER;
    l_print_value 	VARCHAR2(40);

  BEGIN
  gmd_debug.log_initialize('LCF');
    --Load formulation specification details
    OPEN Cur_get_formulation;
    FETCH Cur_get_formulation INTO l_formulation;
    CLOSE Cur_get_formulation;

    --Call the load items procedure here to load the material lines and there item technical data.
    gmd_lcf_fetch_pkg.load_items (V_formulation_spec_id => V_formulation_spec_id,
                                  V_organization_id     => V_organization_id,
                                  V_ingred_pick_base    => l_formulation.ingred_pick_base_ind,
                                  V_formula_no          => V_formula_no,
                                  V_batch_no            => V_batch_no,
                                  V_date		=> V_date);
    --Get the material line count
    OPEN Cur_get_line_count;
    FETCH Cur_get_line_count INTO l_count;
    CLOSE Cur_get_line_count;

    --Product qty after the process loss if any
    --IF (l_formulation.process_loss IS NOT NULL) THEN
      --l_prod_qty := (l_formulation.std_qty - l_formulation.process_loss);
    --ELSE
      l_prod_qty := l_formulation.std_qty;
   --END IF;

    --For each line get the technical parameter value defined as objective ind in formulation
    --Specification screen.
    FOR l_rec IN Cur_get_lineid LOOP
      FOR l_value IN Cur_get_optprm_value (l_formulation.tech_parm_id,l_rec.line_id) LOOP
        i := i + 1;
        l_lt_matrix(0)(i) := NVL(l_value.value,0);
      END LOOP;
    END LOOP;

    --Standard(Gross weight) qty defined.
    l_rt_matrix(1) (0) := 'Standard Qty';
    l_rt_matrix(1) (1) := l_prod_qty;
    l_rt_matrix(1) (2) := 1e20;
    l_rt_matrix(1) (3) := 1e20;

    --Get all material lines Pass the value 1 to them.
    FOR l_rec1 IN Cur_get_lineid LOOP
      l_line_row := l_line_row + 1;
      l_lt_matrix(1)(l_line_row) := l_rec1.conv_factor;
      l_var(l_line_row) := l_rec1.concatenated_segments;
    END LOOP;

    --Get the requirements defined in the material requirement screen.
    FOR l_mat IN Cur_get_matl_req LOOP
      --Get the lineid for each item defined as mateiral requirement
      l_line_id := 1;
      IF l_mat.min_qty IS NOT NULL THEN
      --Increment the row numbers for left and right matrix
        l_row := l_row + 1;
        l_rt_row := l_rt_row + 1;
        FOR l_mat_line IN Cur_get_matreq_line (l_mat.inventory_item_id) LOOP

          --Pass value 0 to all the items which has no min qty defined.
          FOR i IN l_line_id .. (l_mat_line.line_id - 1) loop
            l_lt_matrix(l_row)(i) := 0;
          END LOOP;

          --Pass value 1 all the items which has min qty defined.
          l_lt_matrix(l_row)(l_mat_line.line_id) := l_mat_line.conv_factor;
          l_line_id := l_mat_line.line_id + 1;
        END LOOP; --FOR l_mat_line IN Cur_get_matreq_line (l_mat.inventory_item_id) LOOP

        FOR i IN l_line_id .. l_count loop
          l_lt_matrix(l_row)(i) := 0;
        END LOOP;
        --If the range type is % then multiply the min qty with product qty and divide by 100
        IF (l_mat.range_type = 0) THEN
          l_min_qty := ((l_prod_qty * l_mat.min_qty) / 100);
        ELSE
          l_min_qty := l_mat.min_qty;
        END IF;
        l_rt_matrix(l_rt_row)(0) := l_mat.concatenated_segments;
        l_rt_matrix(l_rt_row)(1) := l_min_qty;
        l_rt_matrix(l_rt_row)(2) := 1e20;
        l_rt_matrix(l_rt_row)(3) := 0;
      END IF; --IF l_mat.min_qty IS NOT NULL THEN

        --Pass the value 0 all the items which has no max qty defined.
      l_line_id := 1;
      IF l_mat.max_qty IS NOT NULL THEN
        --Increment the row numbers for left and right matrix
        l_row := l_row + 1;
        l_rt_row := l_rt_row + 1;
        FOR l_mat_line IN Cur_get_matreq_line (l_mat.inventory_item_id) LOOP
          FOR i IN l_line_id .. (l_mat_line.line_id - 1) loop
            l_lt_matrix(l_row)(i) := 0;
          END LOOP;

          --Pass value 1 all the items which has max qty defined.
          l_lt_matrix(l_row)(l_mat_line.line_id) := l_mat_line.conv_factor;
          l_line_id := l_mat_line.line_id + 1;
        END LOOP; --FOR l_mat_line IN Cur_get_matreq_line (l_mat.inventory_item_id) LOOP

        FOR i IN l_line_id .. l_count loop
          l_lt_matrix(l_row)(i) := 0;
        END LOOP;

        --If the range type is % then multiply the min qty with product qty and divide by 100
        IF (l_mat.range_type = 0) THEN
          l_max_qty := ((l_prod_qty * l_mat.max_qty) / 100);
        ELSE
          l_max_qty := l_mat.max_qty;
        END IF;
        l_rt_matrix(l_rt_row)(0) := l_mat.concatenated_segments;
        l_rt_matrix(l_rt_row)(1) := l_max_qty;
        l_rt_matrix(l_rt_row)(2) := 0;
        l_rt_matrix(l_rt_row)(3) := 1e20;
      END IF; --IF l_mat.max_qty IS NOT NULL THEN
    END LOOP; --FOR l_mat IN Cur_get_matl_req (V_formulation_spec_id) LOOP

    --Get the requirements defined in the compositional requirement screen.
    FOR l_comp IN Cur_get_comp_req (V_formulation_spec_id) LOOP
      l_line_id := 1;
      --Get the lineid for each category defined as compositional requirement
      IF l_comp.min_pct IS NOT NULL THEN
        --Increment the row numbers for left and right matrix
        l_row     := l_row + 1;
        l_rt_row  := l_rt_row + 1;
        FOR l_comp_rec IN Cur_get_category (l_comp.category_id) LOOP
          --Get the conversion factor for each line and pass it to the matrix
          FOR l_factor IN Cur_get_conv_factor (l_comp_rec.line_id) LOOP
            --Pass the value 0 to all the items which has no min pct defined.
            FOR i IN l_line_id .. (l_comp_rec.line_id - 1) LOOP
              l_lt_matrix(l_row)(i) := 0;
            END LOOP;

            l_lt_matrix(l_row)(l_comp_rec.line_id) := l_factor.conv_factor;
            l_line_id := l_comp_rec.line_id + 1;
          END LOOP; -- FOR l_factor IN Cur_get_conv_factor (l_comp_rec.line_id) LOOP
        END LOOP; --FOR l_comp_rec IN Cur_get_category (l_comp.category_id) LOOP

        --Pass the value 0 to all other items
        FOR i IN l_line_id .. l_count LOOP
          l_lt_matrix(l_row)(i) := 0;
        END LOOP;

        --Pass the item name min pct value to the matirx.
        l_rt_matrix(l_rt_row)(0) := l_comp.category_name;
        l_rt_matrix(l_rt_row)(1) := ((l_prod_qty * l_comp.min_pct) /100);
        l_rt_matrix(l_rt_row)(2) := 1e20;
        l_rt_matrix(l_rt_row)(3) := 0;
      END IF; --IF l_comp.min_pct IS NOT NULL THEN

      l_line_id := 1;

      IF l_comp.max_pct IS NOT NULL THEN
        --Increment the row numbers for left and right matrix
        l_row     := l_row + 1;
        l_rt_row  := l_rt_row + 1;
        FOR l_comp_rec IN Cur_get_category (l_comp.category_id) LOOP
          --Get the conversion factor for each line and pass it to the matrix
          FOR l_factor IN Cur_get_conv_factor (l_comp_rec.line_id) LOOP
            --Pass the value 0 to all the items which has no min pct defined.
            FOR i IN l_line_id .. (l_comp_rec.line_id - 1) LOOP
              l_lt_matrix(l_row)(i) := 0;
            END LOOP;

            l_lt_matrix(l_row)(l_comp_rec.line_id) := l_factor.conv_factor;
            l_line_id := l_comp_rec.line_id + 1;
          END LOOP; --FOR l_factor IN Cur_get_conv_factor (l_comp_rec.line_id) LOOP
        END LOOP; --FOR l_comp_rec IN Cur_get_category (l_comp.category_id) LOOP

        --Pass the value 0 to all other items
        FOR i IN l_line_id .. l_count LOOP
          l_lt_matrix(l_row)(i) := 0;
        END LOOP;

        --Pass the item name max pct value to the matirx.
        l_rt_matrix(l_rt_row)(0) := l_comp.category_name;
        l_rt_matrix(l_rt_row)(1) := ((l_prod_qty * l_comp.max_pct) /100);
        l_rt_matrix(l_rt_row)(2) := 0;
        l_rt_matrix(l_rt_row)(3) := 1e20;
      END IF; --IF l_comp.max_pct IS NOT NULL THEN
    END LOOP; --FOR l_comp IN Cur_get_comp_req (V_formulation_spec_id) LOOP

    --Get the requirements defined in the compositional requirement screen.
    FOR l_tech IN Cur_get_tech_req (V_formulation_spec_id) LOOP
      l_line_id := 1;

      IF l_tech.min_value IS NOT NULL THEN
        --Increment the row numbers for left and right matrix
        l_row     := l_row + 1;
        l_rt_row  := l_rt_row + 1;
        --Get the lineid for each parameter defined as technical requirement
        FOR l_tech_value IN Cur_get_tech_value (l_tech.tech_parm_id) LOOP
          --Get the conversion factor for each line and pass it to the matrix
          FOR l_factor IN Cur_get_conv_factor (l_tech_value.line_id) LOOP
            --Pass the value 0 to all the items which has no min pct defined.
            FOR i IN l_line_id .. (l_tech_value.line_id - 1) LOOP
              l_lt_matrix(l_row)(i) := 0;
            END LOOP;

            --Pass the tech parameter value to all the items which has min value defined.
            l_lt_matrix(l_row)(l_tech_value.line_id) := (NVL(l_tech_value.value,0)* l_factor.conv_factor);
            l_line_id := l_tech_value.line_id + 1;
          END LOOP; --FOR l_factor IN Cur_get_conv_factor (l_tech_value.line_id) LOOP
        END LOOP; --FOR l_tech_value IN Cur_get_tech_value (l_tech.tech_parm_id) LOOP

        --Pass the value 0 to all other items
        FOR i IN l_line_id .. l_count LOOP
          l_lt_matrix(l_row)(i) := 0;
        END LOOP;

        --Pass the item name min pct value to the matirx.
        l_rt_matrix(l_rt_row)(0) := l_tech.tech_parm_name;
        l_rt_matrix(l_rt_row)(1) := (l_prod_qty * l_tech.min_value);
        l_rt_matrix(l_rt_row)(2) := 1e20;
        l_rt_matrix(l_rt_row)(3) := 0;
      END IF; --IF l_tech.min_value IS NOT NULL THEN

      l_line_id := 1;

      IF l_tech.max_value IS NOT NULL THEN
        --Increment the row numbers for left and right matrix
        l_row     := l_row + 1;
        l_rt_row  := l_rt_row + 1;
        --Get the lineid for each parameter defined as technical requirement
        FOR l_tech_value IN Cur_get_tech_value (l_tech.tech_parm_id) LOOP
          --Get the conversion factor for each line and pass it to the matrix
          FOR l_factor IN Cur_get_conv_factor (l_tech_value.line_id) LOOP
          --Pass the value 0 to all the items which has no min pct defined.
            FOR i IN l_line_id .. (l_tech_value.line_id - 1) LOOP
              l_lt_matrix(l_row)(i) := 0;
            END LOOP;

            --Pass the tech parameter value to all the items which has max value defined.
            l_lt_matrix(l_row)(l_tech_value.line_id) := (NVL(l_tech_value.value,0)* l_factor.conv_factor);
            l_line_id := l_tech_value.line_id + 1;
          END LOOP;
        END LOOP; --FOR l_tech_value IN Cur_get_tech_value (l_tech.tech_parm_id) LOOP

        --Pass the value 0 to all other items
        FOR i IN l_line_id .. l_count LOOP
          l_lt_matrix(l_row)(i) := 0;
        END LOOP;

        --Pass the item name min pct value to the matirx.
        l_rt_matrix(l_rt_row)(0) := l_tech.tech_parm_name;
        l_rt_matrix(l_rt_row)(1) := (l_prod_qty * l_tech.max_value);
        l_rt_matrix(l_rt_row)(2) := 0;
        l_rt_matrix(l_rt_row)(3) := 1e20;
      END IF; --IF l_tech.max_value IS NOT NULL THEN
    END LOOP; --FOR l_tech IN Cur_get_tech_req (V_formulation_spec_id) LOOP

--change the constraints in the first loop and number of varaibles in second
 /*FOR i IN 0..14 LOOP
      l_print_line := NULL;
      FOR j IN 1..16 LOOP
        l_value := ROUND(l_lt_matrix(i)(j),5);
        l_print_value := RPAD(TO_CHAR(l_value, '9990.99999'), 10);
        l_print_line := l_print_line||l_print_value||' ';
      END LOOP;
      gmd_debug.put_line(l_print_line);
 END LOOP; */

    --After builiding the matrix call the lcf engine routine.
    gmd_lcf_engine.evaluate (P_spec_id     => V_formulation_spec_id,
                             P_constraints => l_lt_matrix.count - 1,
                             P_variables   => l_count,
                             P_matrix      => l_lt_matrix,
                             p_rhs_matrix  => l_rt_matrix,
                             p_var_row     => l_var,
                             X_solved_tab  => l_solved_tab,
                             X_return      => j_return);
    X_return_code := j_return;
      FOR i IN 1 .. l_solved_tab.count LOOP
        OPEN Cur_get_line_dtl(l_solved_tab(i).item);
        FETCH Cur_get_line_dtl INTO l_dtl_lineid,l_inv_item_id,l_detail_uom,l_conv_factor;
        CLOSE Cur_get_line_dtl;

        --Update the qty for each category line id returned from above cursor.
        UPDATE gmd_lcf_category_dtl_gtmp
        SET    qty = l_solved_tab(i).qty
        WHERE  line_id = l_dtl_lineid;

        l_new_qty := l_solved_tab(i).qty;

        --Update quantities for the item returned from the uom routine.
        UPDATE gmd_lcf_details_gtmp
        SET    qty = l_new_qty
        WHERE  concatenated_segments = l_solved_tab(i).item;
      END LOOP;

      --Delete the items where qty is null
      DELETE
      FROM   gmd_lcf_details_gtmp
      WHERE  qty IS NULL OR qty = 0;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_msg_pub.add_exc_msg ('GMD_LCF_FETCH_PKG', 'Generate_Lcf_Data');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        NULL;
  END generate_lcf_data;




  /* following procedures are wrote to debug the procedures materials and technical data */

  PROCEDURE temp_dump IS
    cursor cur_rec IS
      select *
      from gmd_lcf_details_gtmp;
  BEGIN
    FOR L_RECORD IN CUR_REC LOOP
        gmd_debug.put_line('item_no'||l_record.concatenated_segments);
        gmd_debug.put_line('detail_uom'||l_record.detail_uom);
        gmd_debug.put_line('line_id'||l_record.line_id);
        gmd_debug.put_line('qty'||l_record.qty);
        gmd_debug.put_line('min_qty'||l_record.min_qty);
        gmd_debug.put_line('max_qty'||l_record.max_qty);
        gmd_debug.put_line('entity'||l_record.entity_id);
        gmd_debug.put_line('qtymass'||l_record.qty_mass);
        gmd_debug.put_line('massuom'||l_record.mass_uom);
        gmd_debug.put_line('qtyvol'||l_record.qty_vol);
        gmd_debug.put_line('voluom'||l_record.vol_uom);
     END LOOP;
   END temp_dump;

   procedure temp_param IS
       cursor cur_rec1 IS
       select  a.*,b.concatenated_segments
       from    gmd_lcf_tech_data_gtmp a, gmd_lcf_details_gtmp b
       where   a.line_id= b.line_id;
   begin
      FOR L_REC IN CUR_REC1 LOOP
        gmd_debug.put_line('item lineid techparmname value');
        gmd_debug.put_line(l_rec.concatenated_segments|| '-' ||l_rec.line_id|| '-' ||l_rec.tech_parm_name|| '-' ||l_rec.value);
      END LOOP;
   end temp_param;

   procedure temp_category IS
       cursor cur_rec1 IS
       select  *
       from    gmd_lcf_category_dtl_gtmp;
   begin
      FOR L_REC IN CUR_REC1 LOOP
        gmd_debug.put_line('category lineid value_ind');
        gmd_debug.put_line(l_rec.category_id|| '-' ||l_rec.line_id|| '-' ||l_rec.value_ind);
      END LOOP;
   end temp_category;


END GMD_LCF_FETCH_PKG;

/

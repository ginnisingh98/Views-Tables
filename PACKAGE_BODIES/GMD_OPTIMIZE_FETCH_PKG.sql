--------------------------------------------------------
--  DDL for Package Body GMD_OPTIMIZE_FETCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPTIMIZE_FETCH_PKG" AS
/* $Header: GMDOPTMB.pls 120.1 2005/07/13 07:28:26 rajreddy noship $ */

  /*##############################################################
  # NAME
  #	load_optimizer_details
  # SYNOPSIS
  #	proc   load_optimizer_details
  # DESCRIPTION
  #      This procedure inserts the data into temp tables and will
  #      be fetched in the form.
  ###############################################################*/

  PROCEDURE load_optimizer_details (V_entity_id IN NUMBER,V_maintain_type IN NUMBER,
                                    X_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_prod IS
      SELECT *
      FROM   gmd_material_details_gtmp
      WHERE  line_type = 1;
    l_prod_rec     	 Cur_get_prod%ROWTYPE;

    CURSOR Cur_get_prod_param(V_line_id  NUMBER) IS
      SELECT a.*,b.value
      FROM   gmd_technical_parameter_gtmp a, gmd_technical_data_gtmp b
      WHERE  a.tech_parm_id = b.tech_parm_id
             AND a.entity_id = b.entity_id
             AND b.line_id = V_line_id
             AND b.entity_id = V_entity_id
             AND a.data_type IN (5,6,9,10);
    l_prod_param_rec     Cur_get_prod_param%ROWTYPE;

    CURSOR Cur_get_ingred IS
      SELECT *
      FROM   gmd_material_details_gtmp
      WHERE  line_type IN (-1,3)
             ORDER BY line_no;
    l_ingred_rec     Cur_get_ingred%ROWTYPE;

    CURSOR Cur_get_value(V_line_id NUMBER) IS
      SELECT a.*
      FROM   gmd_technical_data_gtmp a, gmd_optimizer_prm_gtmp b
      WHERE  a.entity_id = b.entity_id
             AND a.tech_parm_id = b.tech_parm_id
             AND a.line_id = V_line_id;
    l_value_rec      Cur_get_value%ROWTYPE;
  BEGIN
   /* Inserting the product data to optimize temp tables */
    DELETE FROM gmd_optimizer_hdr_gtmp;
    DELETE FROM gmd_optimizer_prm_gtmp;
    DELETE FROM gmd_optimizer_line_gtmp;
    DELETE FROM gmd_optimizer_value_gtmp;
    OPEN Cur_get_prod;
    FETCH Cur_get_prod INTO l_prod_rec;
    CLOSE Cur_get_prod;
    INSERT INTO GMD_OPTIMIZER_HDR_GTMP
            (ENTITY_ID,MAINTAIN_TYPE,YIELD,INVENTORY_ITEM_ID,PRODUCT_QTY,PRODUCT_UOM)
    VALUES  (V_entity_id,NVL(V_maintain_type,0),100,l_prod_rec.inventory_item_id,l_prod_rec.qty,l_prod_rec.detail_uom);

    OPEN Cur_get_prod_param(l_prod_rec.line_id);
    LOOP
    FETCH Cur_get_prod_param INTO l_prod_param_rec;
    EXIT WHEN Cur_get_prod_param%NOTFOUND;
    INSERT INTO GMD_OPTIMIZER_PRM_GTMP
            (ENTITY_ID,OPTIMIZE_TYPE,TECH_PARM_ID,TECH_PARM_NAME,VALUE,MIN_VALUE,MAX_VALUE,PRECISION,LM_UNIT_CODE)
    VALUES  (V_entity_id,NVL(l_prod_param_rec.optimize_type,0),l_prod_param_rec.tech_parm_id,l_prod_param_rec.tech_parm_name,
             l_prod_param_rec.value,l_prod_param_rec.lowerbound_num,l_prod_param_rec.upperbound_num,
             l_prod_param_rec.signif_figures,l_prod_param_rec.lm_unit_code);
    END LOOP;
    CLOSE Cur_get_prod_param;

    OPEN Cur_get_ingred;
    LOOP
    FETCH Cur_get_ingred INTO l_ingred_rec;
    EXIT WHEN Cur_get_ingred%NOTFOUND;
    INSERT INTO GMD_OPTIMIZER_LINE_GTMP
            (ENTITY_ID,LINE_ID,LINE_TYPE,LINE_NO,INVENTORY_ITEM_ID,DESCRIPTION,
             LOT_NUMBER,QTY,DETAIL_UOM,BUFFER_IND,PARENT_LINE_ID,PRIMARY_QTY,PRIMARY_UOM,
             SECONDARY_QTY,SECONDARY_UOM,QTY_MASS,MASS_UOM,QTY_VOL,VOL_UOM,ROLLUP_IND)
    VALUES  (V_entity_id,l_ingred_rec.line_id,l_ingred_rec.line_type,l_ingred_rec.line_no,l_ingred_rec.inventory_item_id,
             l_ingred_rec.description,l_ingred_rec.lot_number,
             l_ingred_rec.qty,l_ingred_rec.detail_uom,NVL(l_ingred_rec.buffer_ind,0),l_ingred_rec.parent_line_id,
             l_ingred_rec.primary_qty,l_ingred_rec.primary_uom,l_ingred_rec.secondary_qty,l_ingred_rec.secondary_uom,
             l_ingred_rec.qty_mass,l_ingred_rec.mass_uom,l_ingred_rec.qty_vol,l_ingred_rec.vol_uom,l_ingred_rec.rollup_ind);
    OPEN Cur_get_value(l_ingred_rec.line_id);
    LOOP
    FETCH Cur_get_value INTO l_value_rec;
    EXIT WHEN Cur_get_value%NOTFOUND;
    INSERT INTO GMD_OPTIMIZER_VALUE_GTMP
            (ENTITY_ID,LINE_ID,TECH_PARM_ID,TECH_PARM_VALUE)
    VALUES  (l_value_rec.entity_id,l_value_rec.line_id,l_value_rec.tech_parm_id,l_value_rec.value);
    END LOOP;
    CLOSE Cur_get_value;
    END LOOP;
    CLOSE Cur_get_ingred;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_OPTIMZE_FETCH_PKG', 'Load_Optimizer_Details');
      x_return_status := FND_API.g_ret_sts_unexp_error;
  END load_optimizer_details;

    /*##############################################################
  # NAME
  #	calculate
  # SYNOPSIS
  #	proc   calculate
  # DESCRIPTION
  #      This procedure calculates the values for the products
  #      by performing the rollups based on data type.
  ###############################################################*/

  PROCEDURE calculate (V_entity_id	IN	   NUMBER,
  		       V_orgn_id	IN	   NUMBER,
                       X_return_status  OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_prod IS
      SELECT a.tech_parm_name,a.lm_unit_code,a.tech_parm_id,b.data_type
      FROM   gmd_optimizer_prm_gtmp a, gmd_technical_parameter_gtmp b
      WHERE  a.entity_id = V_entity_id
             AND a.entity_id = b.entity_id
             AND a.tech_parm_id = b.tech_parm_id;
  BEGIN
    FOR l_rec IN Cur_get_prod LOOP
      FND_MSG_PUB.INITIALIZE;
      IF l_rec.data_type = 5 THEN
        rollup_wt_pct (V_entity_id	=> V_entity_id,
                       V_parm_name	=> l_rec.tech_parm_name,
                       V_parm_id	=> l_rec.tech_parm_id,
                       X_return_status	=> X_return_status);
      ELSIF l_rec.data_type = 6 THEN
        rollup_vol_pct (V_entity_id	=> V_entity_id,
                       V_parm_name	=> l_rec.tech_parm_name,
                       V_parm_id	=> l_rec.tech_parm_id,
                       X_return_status	=> X_return_status);
      ELSIF l_rec.data_type = 9 THEN
        rollup_equiv_wt (V_entity_id	 => V_entity_id,
                         V_parm_name	 => l_rec.tech_parm_name,
                         V_parm_id	 => l_rec.tech_parm_id,
                         V_unit_code     => l_rec.lm_unit_code,
                         V_orgn_id       => V_orgn_id,
                         X_return_status => X_return_status);
      ELSIF l_rec.data_type = 10 THEN
        rollup_update (V_entity_id	=> V_entity_id,
                       V_parm_name	=> l_rec.tech_parm_name,
                       V_parm_id	=> l_rec.tech_parm_id,
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

  PROCEDURE rollup_wt_pct (V_entity_id		IN		NUMBER,
                           V_parm_name 		IN		VARCHAR2,
                           V_parm_id		IN		NUMBER,
                           X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_get_line_ingred IS
      SELECT NVL(SUM(weight), 0), NVL(SUM(weightpct), 0)
      FROM
       (SELECT qty_mass weight, qty_mass * tech_parm_value weightpct
        FROM   gmd_optimizer_line_gtmp d, gmd_optimizer_value_gtmp t
        WHERE  d.line_id = t.line_id (+)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
        AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1);

    CURSOR Cur_get_line_byprod IS
      SELECT NVL(SUM(weight), 0), NVL(SUM(weightpct), 0)
      FROM
       (SELECT qty_mass weight, qty_mass * tech_parm_value weightpct
        FROM   gmd_material_details_gtmp d, gmd_optimizer_value_gtmp t
        WHERE  d.line_id = t.line_id (+)
        AND    (line_type = 2 OR line_type = 3)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
        AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1
        AND EXISTS (SELECT 1
                    FROM   gmd_material_details_gtmp d1
                    WHERE  line_type = 2
                    AND    d1.parent_line_id = d.parent_line_id));
    X_ingred_wt	  	NUMBER ;
    X_ingred_wtpct	NUMBER ;
    X_byprod_wt		NUMBER ;
    X_byprod_wtpct	NUMBER ;
    X_rollup		NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    OPEN Cur_get_line_ingred;
    FETCH Cur_get_line_ingred INTO X_ingred_wt, X_ingred_wtpct;
    CLOSE Cur_get_line_ingred;

    OPEN Cur_get_line_byprod;
    FETCH Cur_get_line_byprod INTO X_byprod_wt, X_byprod_wtpct;
    CLOSE Cur_get_line_byprod;

    IF (X_ingred_wt - X_byprod_wt) <> 0 THEN
      X_rollup := (X_ingred_wtpct - X_byprod_wtpct) / (X_ingred_wt - X_byprod_wt);
    END IF;


    UPDATE gmd_optimizer_prm_gtmp
    SET    value = X_rollup
    WHERE  tech_parm_id = V_parm_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_OPTIMIZER_PRM_GTMP
               (ENTITY_ID,
  		TECH_PARM_ID,
  		TECH_PARM_NAME,
		VALUE)
          VALUES
	       (V_entity_id,
                V_parm_id,
                V_parm_name,
	        X_rollup);
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_WEIGHT_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_OPTIMIZE_FETCH_PKG', 'Rollup_Wt_Pct');
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

  PROCEDURE rollup_vol_pct (V_entity_id		IN		NUMBER,
                            V_parm_name 	IN		VARCHAR2,
                            V_parm_id		IN		NUMBER,
                            X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_get_line_ing  IS
      SELECT SUM(volume), SUM(volumepct)
      FROM
       (SELECT qty_vol volume, qty_vol * tech_parm_value volumepct
        FROM   gmd_optimizer_line_gtmp d, gmd_optimizer_value_gtmp t
        WHERE  d.line_id = t.line_id (+)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
        AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1);

    CURSOR Cur_get_line_byp IS
      SELECT SUM(volume), SUM(volumepct)
      FROM
       (SELECT qty_vol volume, qty_vol * tech_parm_value volumepct
        FROM   gmd_material_details_gtmp d, gmd_optimizer_value_gtmp t
        WHERE  d.line_id = t.line_id (+)
        AND    (line_type = 2 OR line_type = 3)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
        AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1
        AND EXISTS (SELECT 1
                    FROM   gmd_material_details_gtmp d1
                    WHERE  line_type = 2
                    AND    d1.parent_line_id = d.parent_line_id));

    X_ingred_vol  	NUMBER ;
    X_ingred_volpct	NUMBER ;
    X_byprod_vol	NUMBER ;
    X_byprod_volpct	NUMBER ;
    X_rollup		NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    OPEN Cur_get_line_ing;
    FETCH Cur_get_line_ing INTO X_ingred_vol, X_ingred_volpct;
    CLOSE Cur_get_line_ing;

    OPEN Cur_get_line_byp;
    FETCH Cur_get_line_byp INTO X_byprod_vol, X_byprod_volpct;
    CLOSE Cur_get_line_byp;

    IF (NVL(X_ingred_vol,0) - NVL(X_byprod_vol,0)) <> 0 THEN
      X_rollup := (NVL(X_ingred_volpct,0) - NVL(X_byprod_volpct,0)) / (NVL(X_ingred_vol,0) - NVL(X_byprod_vol,0));
    END IF;

    UPDATE gmd_optimizer_prm_gtmp
    SET    value = X_rollup
    WHERE  tech_parm_id = V_parm_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_OPTIMIZER_PRM_GTMP
               (ENTITY_ID,
  		TECH_PARM_ID,
  		TECH_PARM_NAME,
		VALUE)
          VALUES
	       (V_entity_id,
                V_parm_id,
                V_parm_name,
	        X_rollup);
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_VOLUME_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_OPTIMIZE_FETCH_PKG', 'Rollup_Vol_Pct');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END rollup_vol_pct;

  /*##############################################################
  # NAME
  #	rollup_update
  # SYNOPSIS
  #	proc   rollup_update
  # DESCRIPTION
  #      This procedure gets the values for the products for the
  #      by performing the cost units rollup and updates the same.
  ###############################################################*/

  PROCEDURE rollup_update (V_entity_id		IN		NUMBER,
                           V_parm_name 		IN		VARCHAR2,
                           V_parm_id		IN		NUMBER,
                           X_return_status	OUT NOCOPY	VARCHAR2) IS
    X_rollup_cost NUMBER;
  BEGIN
    X_rollup_cost := rollup_cost_units(V_entity_id,V_parm_name,V_parm_id,X_return_status);

    UPDATE gmd_optimizer_prm_gtmp
    SET    value = X_rollup_cost
    WHERE  tech_parm_id = V_parm_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_OPTIMIZER_PRM_GTMP
               (ENTITY_ID,
  		TECH_PARM_ID,
  		TECH_PARM_NAME,
		VALUE)
          VALUES
	       (V_entity_id,
                V_parm_id,
                V_parm_name,
	        X_rollup_cost);
    END IF;
  END rollup_update;


  /*##############################################################
  # NAME
  #	rollup_cost_units
  # SYNOPSIS
  #	proc   rollup_cost_units
  # DESCRIPTION
  #      This procedure gets the values for the products for the
  #      by performing the cost units rollup.
  ###############################################################*/

  FUNCTION rollup_cost_units (V_entity_id		IN		NUMBER,
                              V_parm_name 		IN		VARCHAR2,
                              V_parm_id			IN		NUMBER,
                              X_return_status		OUT NOCOPY	VARCHAR2) RETURN NUMBER IS

    CURSOR Cur_get_line_ing2 IS
      SELECT NVL(SUM(volumepct), 0)
      FROM
       (SELECT primary_qty * tech_parm_value volumepct
        FROM   gmd_optimizer_line_gtmp d, gmd_optimizer_value_gtmp t
        WHERE  d.line_id = t.line_id (+)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
	AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1);

    CURSOR Cur_get_line_byp2 IS
      SELECT NVL(SUM(volumepct), 0)
      FROM
       (SELECT primary_qty * tech_parm_value volumepct
        FROM   gmd_material_details_gtmp d, gmd_optimizer_value_gtmp t
        WHERE  d.line_id = t.line_id (+)
        AND    (line_type = 2 OR line_type = 3)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
	AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1
        AND EXISTS (SELECT 1
                    FROM   gmd_material_details_gtmp d1
                    WHERE  line_type = 2
                    AND    d1.parent_line_id = d.parent_line_id));

    X_ingred_volpct	NUMBER ;
    X_byprod_volpct	NUMBER ;
    X_rollup		NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    OPEN Cur_get_line_ing2;
    FETCH Cur_get_line_ing2 INTO  X_ingred_volpct;
    CLOSE Cur_get_line_ing2;

    OPEN Cur_get_line_byp2;
    FETCH Cur_get_line_byp2 INTO  X_byprod_volpct;
    CLOSE Cur_get_line_byp2;

    IF (X_ingred_volpct - X_byprod_volpct) <> 0 THEN
      X_rollup := (X_ingred_volpct - X_byprod_volpct);
    END IF;
    RETURN(X_rollup);

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_COST_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_OPTIMIZE_FETCH_PKG', 'Rollup_Cost_Units');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END rollup_cost_units;

  /*##############################################################
  # NAME
  #	rollup_equiv_wt
  # SYNOPSIS
  #	proc   rollup_equiv_wt
  # DESCRIPTION
  #      This procedure gets the values for the products
  #      by performing the equiv wt rollup.
  ###############################################################*/

  PROCEDURE rollup_equiv_wt (V_entity_id	IN		NUMBER,
                             V_parm_name 	IN		VARCHAR2,
                             V_parm_id		IN		NUMBER,
                             V_unit_code	IN		VARCHAR2,
                             V_orgn_id		IN		NUMBER,
                             X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_get_line_ing3  IS
      SELECT d.qty,d.detail_uom,d.lot_number,t.tech_parm_value,d.inventory_item_id,p.tpformula_id
      FROM   gmd_optimizer_line_gtmp d, gmd_optimizer_value_gtmp t, gmd_material_details_gtmp p
      WHERE  d.line_id = t.line_id (+)
      AND    d.entity_id = t.entity_id (+)
      AND    d.entity_id = p.entity_id
      AND    d.line_id = p.line_id
      AND    d.entity_id = V_entity_id
      AND    t.tech_parm_id (+) = V_parm_id
      AND    t.tech_parm_value IS NOT NULL
      AND    d.rollup_ind = 1;

    CURSOR Cur_get_line_byp3  IS
      SELECT qty,detail_uom,lot_number,tech_parm_value,inventory_item_id,d.tpformula_id
      FROM   gmd_material_details_gtmp d, gmd_optimizer_value_gtmp t
      WHERE  d.line_id = t.line_id (+)
      AND    (line_type = 2 OR line_type = 3)
      AND    d.entity_id = t.entity_id (+)
      AND    d.entity_id = V_entity_id
      AND    t.tech_parm_id (+) = V_parm_id
      AND    t.tech_parm_value IS NOT NULL
      AND    rollup_ind = 1
      AND EXISTS (SELECT 1
                  FROM   gmd_material_details_gtmp d1
                  WHERE  line_type = 2
                  AND    d1.parent_line_id = d.parent_line_id);

    X_ingred_equiv	NUMBER := 0 ;
    X_byprod_equiv	NUMBER := 0 ;
    X_ingred_mass	NUMBER := 0 ;
    X_byprod_mass	NUMBER := 0 ;
    l_equiv_qty		NUMBER;
    X_rollup		NUMBER;
    l_error		NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    FOR l_rec IN Cur_get_line_ing3 LOOP
      IF (l_rec.detail_uom <> V_unit_code) THEN
        l_equiv_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_rec.inventory_item_id,
                                              		        pformula_id => NVL(l_rec.tpformula_id,0),
                                              		        plot_number => l_rec.lot_number,
                                                                pcur_qty    => l_rec.qty,
                                                                pcur_uom    => l_rec.detail_uom,
                                                                pnew_uom    => V_unit_code,
                                                                patomic	    => 0,
                                                                plab_id	    => V_orgn_id,
                                                                pcnv_factor => 0);
        IF l_equiv_qty < 0 THEN
          l_error := 1;
          EXIT;
        END IF;
      ELSE
        l_equiv_qty := l_rec.qty;
      END IF;
      X_ingred_equiv := X_ingred_equiv + (l_equiv_qty / l_rec.tech_parm_value);
      X_ingred_mass  := X_ingred_mass + X_ingred_equiv;
    END LOOP;
    IF L_error <> 1 THEN
      FOR L_rec IN cur_get_line_byp3 LOOP
        IF (l_rec.detail_uom <> V_unit_code) THEN
          l_equiv_qty := gmd_labuom_calculate_pkg.uom_conversion (pitem_id    => l_rec.inventory_item_id,
                                              		          pformula_id => NVL(l_rec.tpformula_id,0),
                                              		          plot_number => l_rec.lot_number,
                                                                  pcur_qty    => l_rec.qty,
                                                                  pcur_uom    => l_rec.detail_uom,
                                                                  pnew_uom    => V_unit_code,
                                                                  patomic     => 0,
                                                                  plab_id     => V_orgn_id,
                                                                  pcnv_factor => 0);
          IF l_equiv_qty < 0 THEN
            l_error := 1;
            EXIT;
          END IF;
        ELSE
          l_equiv_qty := l_rec.qty;
        END IF;
        X_byprod_equiv := X_byprod_equiv + (l_equiv_qty / l_rec.tech_parm_value);
        X_byprod_mass  := X_byprod_mass + X_ingred_equiv;
      END LOOP;
    END IF;
    IF(l_error = 1) THEN
      UPDATE gmd_optimizer_prm_gtmp
      SET    value = NULL
      WHERE  tech_parm_id = V_parm_id;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    ELSE
      IF (X_ingred_mass - X_byprod_mass) <> 0 THEN
        X_rollup := (X_ingred_equiv - X_byprod_equiv) / (X_ingred_mass - X_byprod_mass);
      END IF;
      UPDATE gmd_optimizer_prm_gtmp
      SET    value = X_rollup
      WHERE  tech_parm_id = V_parm_id;

      IF SQL%NOTFOUND THEN
          INSERT INTO GMD_OPTIMIZER_PRM_GTMP
               (ENTITY_ID,
  		TECH_PARM_ID,
  		TECH_PARM_NAME,
		VALUE)
          VALUES
	       (V_entity_id,
                V_parm_id,
                V_parm_name,
	        X_rollup);
      END IF;
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_EQUIV_WEIGHT_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_OPTIMIZE_FETCH_PKG', 'Rollup_Equiv_Wt');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END rollup_equiv_wt;

  /*##############################################################
  # NAME
  #	is_lot_selected
  # SYNOPSIS
  #	proc  is_lot_selected
  # DESCRIPTION
  #      This function will check if nay lots are selected for optimzation.
  ###############################################################*/

  FUNCTION is_lot_selected(V_parentline_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR Cur_get_select IS
      SELECT 1
      FROM   DUAL
      WHERE  EXISTS (SELECT 1
                     FROM gmd_optimizer_line_gtmp
                     WHERE buffer_ind = 1
		     AND line_type = 3
                     AND parent_line_id = V_parentline_id);
    l_exist NUMBER;
  BEGIN
    OPEN Cur_get_select;
    FETCH Cur_get_select INTO l_exist;
    IF (Cur_get_select%FOUND) THEN
      CLOSE Cur_get_select;
      RETURN('T');
    END IF;
    CLOSE Cur_get_select;
    RETURN('F');
  END is_lot_selected;

  /*##############################################################
  # NAME
  #	consider_line
  # SYNOPSIS
  #	proc  consider_line
  # DESCRIPTION
  #      This function will retunr the T or F based on the lot selected
  #      for that item.
  ###############################################################*/

  FUNCTION consider_line(V_line_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR Cur_get_linetype IS
      SELECT line_type,parent_line_id
      FROM   gmd_optimizer_line_gtmp
      WHERE  line_id = V_line_id;
    l_line_type      NUMBER;
    l_parent_line_id NUMBER;
  BEGIN
    OPEN Cur_get_linetype;
    FETCH Cur_get_linetype INTO l_line_type, l_parent_line_id;
    CLOSE Cur_get_linetype;
    IF (is_lot_selected(l_parent_line_id) = 'T') THEN
      IF (l_line_type = 3) THEN
        RETURN('T');
      ELSE
        RETURN('F');
      END IF;
    ELSE
      IF (l_line_type = 3) THEN
        RETURN('F');
      ELSE
        RETURN('T');
      END IF;
    END IF;
  END consider_line;

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

  PROCEDURE update_line_mass_vol_qty (V_orgn_id  		IN	NUMBER,
                                      V_line_id			IN	NUMBER,
                                      V_density_parameter	IN	VARCHAR2,
                                      V_mass_uom		IN	VARCHAR2,
                                      V_vol_uom			IN	VARCHAR2,
                                      X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_line_qty IS
      SELECT inventory_item_id, lot_number, qty,
             detail_uom,primary_uom,secondary_uom
      FROM   gmd_optimizer_line_gtmp
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

    UPDATE gmd_optimizer_line_gtmp
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
      fnd_msg_pub.add_exc_msg ('GMD_OPTIMIZE_FETCH_PKG', 'Update_Line_Mass_Vol_Qty');
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
      FROM   gmd_optimizer_line_gtmp
      WHERE  rollup_ind = 1
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
      IF l_return_status <> x_return_status THEN
        X_return_status := l_return_status;
      END IF;
    END LOOP;
  END update_mass_vol_qty;







END GMD_OPTIMIZE_FETCH_PKG;

/

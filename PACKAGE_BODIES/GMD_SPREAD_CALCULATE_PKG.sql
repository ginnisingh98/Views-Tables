--------------------------------------------------------
--  DDL for Package Body GMD_SPREAD_CALCULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPREAD_CALCULATE_PKG" AS
/* $Header: GMDSPDCB.pls 120.6.12010000.3 2009/05/21 14:25:59 rnalla ship $ */

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
      SELECT d.*, p.tech_parm_name, p.data_type, p.lm_unit_code,p.sort_seq,p.tech_parm_id
      FROM   gmd_material_details_gtmp d, gmd_technical_parameter_gtmp p
      WHERE  d.entity_id = V_entity_id
      AND    p.data_type > 3 AND (p.data_type = 4 OR d.line_type = 1);
    l_count NUMBER;
    j       NUMBER;
    l_data  VARCHAR2(2000);
    l_expression VARCHAR2(2000);
    l_density    VARCHAR2(2000);
  BEGIN
    DELETE FROM GMD_SPREAD_ERRORS_GTMP;
    FOR l_rec IN Cur_get_prod LOOP
      FND_MSG_PUB.INITIALIZE;
      IF ((l_rec.data_type = 4) OR (l_rec.line_type = 1 AND l_rec.data_type = 11)) THEN
        evaluate_expression (V_entity_id       => V_entity_id,
                       	     V_line_id	       => l_rec.line_id,
                             V_parm_name       => l_rec.tech_parm_name,
                             V_parm_id	       => l_rec.tech_parm_id,
                             V_sort_seq	       => l_rec.sort_seq,
                             X_expression      => l_expression,
                             X_return_status   => X_return_status);
      ELSIF (l_rec.data_type = 5 OR l_rec.data_type = 12) THEN
        rollup_wt_pct (V_entity_id	=> V_entity_id,
                       V_line_id	=> l_rec.line_id,
                       V_parm_name	=> l_rec.tech_parm_name,
                       V_parm_id	=> l_rec.tech_parm_id,
                       V_sort_seq	=> l_rec.sort_seq,
                       X_return_status	=> X_return_status);
      ELSIF l_rec.data_type IN (6, 7) THEN
        rollup_vol_pct(V_entity_id	=> V_entity_id,
		       V_orgn_id        => V_orgn_id,
                       V_line_id	=> l_rec.line_id,
                       V_parm_name	=> l_rec.tech_parm_name,
                       V_parm_id	=> l_rec.tech_parm_id,
                       V_sort_seq	=> l_rec.sort_seq,
                       X_return_status	=> X_return_status);
      ELSIF l_rec.data_type = 8 THEN
        rollup_cost_update(V_entity_id	   => V_entity_id,
                           V_line_id	   => l_rec.line_id,
                           V_parm_name	   => l_rec.tech_parm_name,
                           V_parm_id	   => l_rec.tech_parm_id,
                           V_primary_qty   => l_rec.primary_qty,
                           V_sort_seq	   => l_rec.sort_seq,
                           X_return_status => X_return_status);
      ELSIF l_rec.data_type = 9 THEN
        rollup_equiv_wt   (V_entity_id	   => V_entity_id,
                           V_line_id	   => l_rec.line_id,
                           V_parm_name	   => l_rec.tech_parm_name,
                           V_parm_id	   => l_rec.tech_parm_id,
                           V_unit_code     => l_rec.lm_unit_code,
                           V_orgn_id       => V_orgn_id,
                           V_sort_seq	   => l_rec.sort_seq,
                           X_return_status => X_return_status);
      ELSIF l_rec.data_type = 10 THEN
        rollup_update (V_entity_id	=> V_entity_id,
                       V_line_id	=> l_rec.line_id,
                       V_parm_name	=> l_rec.tech_parm_name,
                       V_parm_id	=> l_rec.tech_parm_id,
                       V_sort_seq	=> l_rec.sort_seq,
                       X_return_status	=> X_return_status);
      ELSE
        NULL;
      END IF;
      l_count := FND_MSG_PUB.COUNT_MSG;
      FOR i IN 1 .. l_count LOOP
        FND_MSG_PUB.GET(P_msg_index => i, P_data  => l_data, p_msg_index_out => j, P_encoded => 'F');
        INSERT INTO GMD_SPREAD_ERRORS_GTMP
             (ENTITY_ID,LINE_ID,LINE_TYPE,INVENTORY_ITEM_ID,CONCATENATED_SEGMENTS,LOT_NUMBER,
              TECH_PARM_ID,TECH_PARM_NAME,ERROR_MESSAGE,EXPRESSION_TYPE)
        VALUES
             (V_entity_id,l_rec.line_id,l_rec.line_type,l_rec.inventory_item_id,
              l_rec.concatenated_segments,l_rec.lot_number,
	      l_rec.tech_parm_id,l_rec.tech_parm_name,l_data,l_expression);
      END LOOP;
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
                           V_line_id 		IN		NUMBER,
                           V_parm_name 		IN		VARCHAR2,
                           V_parm_id		IN		NUMBER,
                           V_sort_seq	        IN		NUMBER,
                           X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_get_line (V_line_type NUMBER) IS
      SELECT NVL(SUM(weight), 0), NVL(SUM(weightpct), 0)
      FROM
       (SELECT qty_mass weight, qty_mass * value weightpct
        FROM   gmd_material_details_gtmp d, gmd_technical_data_gtmp t
        WHERE  line_type <> 1
        AND    (line_type = V_line_type OR line_type = 3)
        AND    d.line_id = t.line_id (+)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
        AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1
        AND EXISTS (SELECT 1
                    FROM   gmd_material_details_gtmp d1
                    WHERE  line_type = V_line_type
                    AND    d1.parent_line_id = d.parent_line_id));
    X_ingred_wt	  	NUMBER ;
    X_ingred_wtpct	NUMBER ;
    X_byprod_wt		NUMBER ;
    X_byprod_wtpct	NUMBER ;
    X_rollup		NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    OPEN Cur_get_line (-1);
    FETCH Cur_get_line INTO X_ingred_wt, X_ingred_wtpct;
    CLOSE Cur_get_line;

    OPEN Cur_get_line (2);
    FETCH Cur_get_line INTO X_byprod_wt, X_byprod_wtpct;
    CLOSE Cur_get_line;

    IF (X_ingred_wt - X_byprod_wt) <> 0 THEN
      X_rollup := (X_ingred_wtpct - X_byprod_wtpct) / (X_ingred_wt - X_byprod_wt);
    END IF;


    UPDATE gmd_technical_data_gtmp
    SET value = X_rollup, num_data = X_rollup
    WHERE line_id = V_line_id
    AND   tech_parm_id = V_parm_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,
  		LINE_ID,
  		SORT_SEQ,
  		TECH_PARM_NAME,
  		TECH_PARM_ID,
		VALUE,
		NUM_DATA)
      VALUES
		(V_entity_id,
                 V_line_id,
                 V_sort_seq,
                 V_parm_name,
                 V_parm_id,
		 X_rollup,
		 X_rollup);
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_WEIGHT_CALCULATE','V_PARM_NAME',V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_CALCULATE_PKG', 'Rollup_Wt_Pct');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END rollup_wt_pct;

  /*##############################################################
  # NAME
  #	evaluate_expression
  # SYNOPSIS
  #	proc   evaluate_expression
  # DESCRIPTION
  #      This procedure gets the values for the products for the
  #      by performing the expression evaluation.
  ###############################################################*/

  PROCEDURE evaluate_expression (V_entity_id		IN		NUMBER,
                                 V_line_id 		IN		NUMBER,
                                 V_parm_name 		IN		VARCHAR2,
                                 V_parm_id		IN		NUMBER,
                                 V_sort_seq	        IN		NUMBER,
                                 X_expression		OUT NOCOPY	VARCHAR2,
                                 X_return_status	OUT NOCOPY	VARCHAR2) IS
    X_rollup		NUMBER;
    l_param_id		NUMBER;
    l_value             NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;
    gmd_expression_util.evaluate_expression (p_entity_id => v_entity_id,
   					     p_line_id => v_line_id,
   					     p_tech_parm_id => v_parm_id,
   					     X_value => l_value,
   					     X_expression => X_expression,
   					     x_return_status => x_return_status);

    UPDATE gmd_technical_data_gtmp
    SET value = l_value, num_data = l_value
    WHERE line_id = V_line_id
    AND   tech_parm_id = V_parm_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,
  		LINE_ID,
  		SORT_SEQ,
  		TECH_PARM_NAME,
  		TECH_PARM_ID,
		VALUE,
		NUM_DATA)
      VALUES
		(V_entity_id,
                 V_line_id,
                 V_sort_seq,
                 V_parm_name,
                 V_parm_id,
		 l_value,
		 l_value);
    END IF;

    IF X_return_status <>  FND_API.g_ret_sts_success THEN
      gmd_api_grp.log_message('GMD_EXPRESSION_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_CALCULATE_PKG', 'Evaluate_Expression');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END evaluate_expression;

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
                            V_orgn_id           IN              NUMBER,
                            V_line_id 		IN		NUMBER,
                            V_parm_name 	IN		VARCHAR2,
                            V_parm_id		IN		NUMBER,
                            V_sort_seq	        IN		NUMBER,
                            X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_get_line1 (V_line_type NUMBER) IS
      SELECT SUM(volume), SUM(volumepct)
      FROM
       (SELECT qty_vol volume, qty_vol * value volumepct
        FROM   gmd_material_details_gtmp d, gmd_technical_data_gtmp t
        WHERE  line_type <> 1
        AND    (line_type = V_line_type OR line_type = 3)
        AND    d.line_id = t.line_id (+)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
	AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1
        AND EXISTS (SELECT 1
                    FROM   gmd_material_details_gtmp d1
                    WHERE  line_type = V_line_type
                    AND    d1.parent_line_id = d.parent_line_id));
    CURSOR Cur_std_um (V_uom_type VARCHAR2) IS
      SELECT uom_code
      FROM   mtl_units_of_measure
      WHERE  uom_class = V_uom_type;

    X_ingred_vol  	NUMBER ;
    X_ingred_volpct	NUMBER ;
    X_byprod_vol	NUMBER ;
    X_byprod_volpct	NUMBER ;
    X_rollup		NUMBER;
    X_density_parameter VARCHAR2(240);
    X_mass_uom 		VARCHAR2(30);
    X_vol_uom  		VARCHAR2(30);
    X_uom_type 		VARCHAR2(30);
    L_return_status     VARCHAR2(1);

    NO_PARAMETER EXCEPTION;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    OPEN Cur_get_line1 (-1);
    FETCH Cur_get_line1 INTO X_ingred_vol, X_ingred_volpct;
    CLOSE Cur_get_line1;

    OPEN Cur_get_line1 (2);
    FETCH Cur_get_line1 INTO X_byprod_vol, X_byprod_volpct;
    CLOSE Cur_get_line1;

    IF (NVL(X_ingred_vol,0) - NVL(X_byprod_vol,0)) <> 0 THEN
      X_rollup := (NVL(X_ingred_volpct,0) - NVL(X_byprod_volpct,0)) / (NVL(X_ingred_vol,0) - NVL(X_byprod_vol,0));
    END IF;

    UPDATE gmd_technical_data_gtmp
    SET    value = X_rollup,
           num_data = X_rollup
    WHERE  line_id = V_line_id
           AND tech_parm_id = V_parm_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,
  		LINE_ID,
  		SORT_SEQ,
  		TECH_PARM_NAME,
  		TECH_PARM_ID,
		VALUE,
		NUM_DATA)
           VALUES
		(V_entity_id,
                V_line_id,
                V_sort_seq,
                V_parm_name,
                V_parm_id,
		X_rollup,
		X_rollup);
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_VOLUME_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
    gmd_api_grp.fetch_parm_values(P_orgn_id       => v_orgn_id,
                                  P_parm_name     => 'GMD_MASS_UM_TYPE',
                                  P_parm_value    => X_uom_type,
                                  X_return_status => L_return_status);
    IF (L_return_status <> FND_API.g_ret_sts_success) THEN
      RAISE NO_PARAMETER;
    END IF;
    OPEN Cur_std_um (X_uom_type);
    FETCH Cur_std_um INTO X_mass_uom;
    CLOSE Cur_std_um;

    gmd_api_grp.fetch_parm_values(P_orgn_id       => v_orgn_id,
                                  P_parm_name     => 'GMD_VOLUME_UM_TYPE',
                                  P_parm_value    => X_uom_type,
                                  X_return_status => L_return_status);
    IF (L_return_status <> FND_API.g_ret_sts_success) THEN
      RAISE NO_PARAMETER;
    END IF;

    OPEN Cur_std_um (X_uom_type);
    FETCH Cur_std_um INTO X_vol_uom;
    CLOSE Cur_std_um;
    X_density_parameter := FND_PROFILE.VALUE('LM$DENSITY');

    IF (V_parm_name = X_density_parameter) THEN
     gmd_spread_fetch_pkg.update_line_mass_vol_qty (V_orgn_id	        => V_orgn_id,
                                                    V_line_id	        => V_line_id,
                                                    V_density_parameter => X_density_parameter,
                                                    V_mass_uom	        => X_mass_uom,
                                                    V_vol_uom	        => X_vol_uom,
                                                    X_return_status	=> X_return_status);
    END IF;
    IF x_return_status <> x_return_status THEN
      X_return_status := x_return_status;
    END IF;

  EXCEPTION
    WHEN NO_PARAMETER THEN
      fnd_msg_pub.add_exc_msg ('GMD', 'GMD_PARM_NOT_FOUND');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_CALCULATE_PKG', 'Rollup_Vol_Pct');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END rollup_vol_pct;

  /*##############################################################
  # NAME
  #	rollup_cost_update
  # SYNOPSIS
  #	proc   rollup_cost_update
  # DESCRIPTION
  #      This procedure gets the values for the products for the
  #      by performing the cost units rollup and updates the same.
  ###############################################################*/

  PROCEDURE rollup_cost_update(V_entity_id		IN		NUMBER,
                               V_line_id 		IN		NUMBER,
                               V_parm_name 		IN		VARCHAR2,
                               V_parm_id		IN		NUMBER,
                               V_primary_qty 		IN		VARCHAR2,
                               V_sort_seq	        IN		NUMBER,
                               X_return_status		OUT NOCOPY	VARCHAR2) IS
    X_rollup_cost NUMBER;
  BEGIN
    X_rollup_cost := rollup_cost_units(V_entity_id,V_line_id,V_parm_name,V_parm_id,X_return_status);
    IF V_primary_qty > 0 THEN
      X_rollup_cost := X_rollup_cost / V_primary_qty;
    ELSE
      X_rollup_cost := 0;
    END IF;
    UPDATE gmd_technical_data_gtmp
    SET    value = X_rollup_cost,
           num_data = X_rollup_cost
    WHERE  line_id = V_line_id
    AND    tech_parm_id = V_parm_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,
  		LINE_ID,
  		SORT_SEQ,
  		TECH_PARM_NAME,
  		TECH_PARM_ID,
		VALUE,
		NUM_DATA)
          VALUES
		(V_entity_id,
                 V_line_id,
                 V_sort_seq,
                 V_parm_name,
                 V_parm_id,
		 X_rollup_cost,
		 X_rollup_cost);
    END IF;
  END rollup_cost_update;

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
                           V_line_id 		IN		NUMBER,
                           V_parm_name 		IN		VARCHAR2,
                           V_parm_id		IN		NUMBER,
                           V_sort_seq	        IN		NUMBER,
                           X_return_status	OUT NOCOPY	VARCHAR2) IS
    X_rollup_cost NUMBER;
  BEGIN
    X_rollup_cost := rollup_cost_units(V_entity_id,V_line_id,V_parm_name,V_parm_id,X_return_status);

    UPDATE gmd_technical_data_gtmp
    SET    value = X_rollup_cost,
           num_data = X_rollup_cost
    WHERE  line_id = V_line_id
    AND    tech_parm_id = V_parm_id;

    IF SQL%NOTFOUND THEN
          INSERT INTO GMD_TECHNICAL_DATA_GTMP
               (ENTITY_ID,
  		LINE_ID,
  		SORT_SEQ,
  		TECH_PARM_NAME,
  		TECH_PARM_ID,
		VALUE,
		NUM_DATA)
          VALUES
		(V_entity_id,
                V_line_id,
                V_sort_seq,
                V_parm_name,
                V_parm_id,
		X_rollup_cost,
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
                              V_line_id 		IN		NUMBER,
                              V_parm_name 		IN		VARCHAR2,
                              V_parm_id			IN		NUMBER,
                              X_return_status		OUT NOCOPY	VARCHAR2) RETURN NUMBER IS

    CURSOR Cur_get_line2 (V_line_type NUMBER) IS
      SELECT NVL(SUM(volumepct), 0)
      FROM
       (SELECT primary_qty * value volumepct
        FROM   gmd_material_details_gtmp d, gmd_technical_data_gtmp t
        WHERE  line_type <> 1
        AND    (line_type = V_line_type OR line_type = 3)
        AND    d.line_id = t.line_id (+)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
	AND    t.tech_parm_id (+) = V_parm_id
        AND    rollup_ind = 1
        AND EXISTS (SELECT 1
                    FROM   gmd_material_details_gtmp d1
                    WHERE  line_type = V_line_type
                    AND    d1.parent_line_id = d.parent_line_id));
    X_ingred_volpct	NUMBER ;
    X_byprod_volpct	NUMBER ;
    X_rollup		NUMBER;
  BEGIN
    X_return_status := FND_API.g_ret_sts_success;

    OPEN Cur_get_line2 (-1);
    FETCH Cur_get_line2 INTO  X_ingred_volpct;
    CLOSE Cur_get_line2;

    OPEN Cur_get_line2 (2);
    FETCH Cur_get_line2 INTO  X_byprod_volpct;
    CLOSE Cur_get_line2;

    IF (X_ingred_volpct - X_byprod_volpct) <> 0 THEN
      X_rollup := (X_ingred_volpct - X_byprod_volpct);
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_COST_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;
    RETURN(X_rollup);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_CALCULATE_PKG', 'Rollup_Cost_Units');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN(0);
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
                             V_line_id 		IN		NUMBER,
                             V_parm_name 	IN		VARCHAR2,
                             V_parm_id		IN		NUMBER,
                             V_unit_code	IN		VARCHAR2,
                             V_orgn_id		IN		NUMBER,
                             V_sort_seq	        IN		NUMBER,
                             X_return_status	OUT NOCOPY	VARCHAR2) IS

    CURSOR Cur_get_line3 (V_line_type NUMBER) IS
      SELECT   qty,detail_uom,value,inventory_item_id,lot_number,tpformula_id
        FROM   gmd_material_details_gtmp d, gmd_technical_data_gtmp t
        WHERE  line_type <> 1
        AND    (line_type = V_line_type OR line_type = 3)
        AND    d.line_id = t.line_id (+)
        AND    d.entity_id = t.entity_id (+)
        AND    d.entity_id = V_entity_id
	AND    t.tech_parm_id (+) = V_parm_id
        AND    t.value IS NOT NULL
        AND    rollup_ind = 1
        AND EXISTS (SELECT 1
                    FROM   gmd_material_details_gtmp d1
                    WHERE  line_type = V_line_type
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
    FOR l_rec IN Cur_get_line3(-1) LOOP
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
      X_ingred_equiv := X_ingred_equiv + NVL((l_equiv_qty / l_rec.value),0);
      X_ingred_mass  := X_ingred_mass + l_equiv_qty;
    END LOOP;
    IF L_error <> 1 THEN
      FOR L_rec IN cur_get_line3(2) LOOP
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
        X_byprod_equiv := X_byprod_equiv + NVL((l_equiv_qty / l_rec.value),0);
        X_byprod_mass  := X_byprod_mass + l_equiv_qty;
      END LOOP;
    END IF;
    IF(l_error = 1) THEN
      UPDATE gmd_technical_data_gtmp
      SET    value = NULL,
             num_data = NULL
      WHERE  line_id = V_line_id
      AND    tech_parm_id = V_parm_id;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    ELSE
      IF (X_ingred_mass - X_byprod_mass) <> 0 THEN
        X_rollup := (X_ingred_equiv - X_byprod_equiv) / (X_ingred_mass - X_byprod_mass);
      END IF;
      UPDATE gmd_technical_data_gtmp
      SET    value = X_rollup,
             num_data = X_rollup
      WHERE  line_id = V_line_id
      AND    tech_parm_id = V_parm_id;

      IF SQL%NOTFOUND THEN
            INSERT INTO GMD_TECHNICAL_DATA_GTMP
                 (ENTITY_ID,
  		  LINE_ID,
  		  SORT_SEQ,
  		  TECH_PARM_NAME,
  		  TECH_PARM_ID,
		  VALUE,
		  NUM_DATA)
            VALUES
		  (V_entity_id,
                  V_line_id,
                  V_sort_seq,
                  V_parm_name,
                  V_parm_id,
		  X_rollup,
		  X_rollup);
      END IF;
    END IF;

    IF X_rollup IS NULL THEN
      gmd_api_grp.log_message('GMD_EQUIV_WEIGHT_CALCULATE','V_PARM_NAME', V_parm_name);
      X_return_status := FND_API.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SPREAD_CALCULATE_PKG', 'Rollup_Equiv_Wt');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END rollup_equiv_wt;


  /* following procedures are wrote to debug the procedures */
    procedure temp_dump (V_entity_id IN NUMBER) IS
       cursor cur_rec IS
       select *
       from gmd_material_details_gtmp
       where   entity_id = V_entity_id
       AND    rollup_ind = 1;
    begin
FOR L_RECORD IN CUR_REC LOOP
        gmd_debug.put_line('item_no'||l_record.concatenated_segments);
        gmd_debug.put_line('item_um'||l_record.detail_uom);
        gmd_debug.put_line('item_qty'||l_record.qty);
        gmd_debug.put_line('line_id'||l_record.line_id);
        gmd_debug.put_line('entity'||l_record.entity_id);
        gmd_debug.put_line('qtymass'||l_record.qty_mass);
        gmd_debug.put_line('massuom'||l_record.mass_uom);
        gmd_debug.put_line('qtyvol'||l_record.qty_vol);
        gmd_debug.put_line('voluom'||l_record.vol_uom);
        gmd_debug.put_line('rollupind'||l_record.rollup_ind);
        END LOOP;
   end temp_dump;

    procedure temp_param (V_entity_id IN NUMBER,V_line_id IN NUMBER) IS
       cursor cur_rec1 IS
       select  a.*,b.concatenated_segments,b.lot_number,b.qty
       from    gmd_technical_data_gtmp a, gmd_material_details_gtmp b
       where   a.entity_id = V_entity_id
       AND     a.line_id= b.line_id
       and    (v_line_id is null or a.line_id = v_line_id);
    begin
FOR L_REC IN CUR_REC1 LOOP
gmd_debug.put_line('item qty lotno lineid techparmname value');
gmd_debug.put_line(l_rec.concatenated_segments|| '-' ||l_rec.qty|| '-' ||l_rec.lot_number|| '-' ||l_rec.line_id|| '-' ||l_rec.tech_parm_name|| '-' ||l_rec.value);
        END LOOP;
   end temp_param;


  /*##############################################################
  # NAME
  #	auto_calc_product
  # SYNOPSIS
  #	proc   auto_calc_product
  # DESCRIPTION
  #   Kapil M 12-FEB-2007  Bug# 5716318 : Auto-Prod Calcualtion ME
  #         Added new procedure - auto_calc_product
  #   Kishore - 16-Mar-2009 - Bug No.8317833 : Changed unit_of_measure to
  #                                        uom_code for the cursor get_unit_of_measure.
  #   Raju 21-May-2009 Bug 8511720 is fixed by adding union to the exisitng cursor
  #                    to include newly added ingredients and byprods.
  ###############################################################*/
   procedure auto_calc_product(V_entity_id		IN		NUMBER,
                                x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY      NUMBER,
                                 x_msg_data         OUT NOCOPY      VARCHAR2 ) IS

    CURSOR Cur_get_org_id IS
      SELECT OWNER_ORGANIZATION_ID
      FROM FM_FORM_MST
      WHERE formula_id = V_entity_id;

    CURSOR Cur_get_ingredient_qty(V_entity_id NUMBER) IS
    SELECT a.qty , a.detail_uom , a.inventory_item_id
    FROM gmd_material_details_gtmp a , fm_matl_dtl b
    where a.entity_id = V_entity_id
    and b.formula_id = V_entity_id
    and a.inventory_item_id = b.inventory_item_id
    and b.CONTRIBUTE_YIELD_IND = 'Y'
    and a.line_type = b.line_type
    and b.line_type = -1
    UNION
    SELECT a.qty , a.detail_uom , a.inventory_item_id
    FROM gmd_material_details_gtmp a
    where a.entity_id = V_entity_id
    and a.line_type = -1
    and a.inventory_item_id NOT IN (SELECT b.inventory_item_id
                                    FROM   fm_matl_dtl b
                                    WHERE  b.formula_id = V_entity_id
                                    and b.line_type = -1);


    CURSOR Cur_get_byproduct_qty(V_entity_id NUMBER) IS
    SELECT a.qty , a.detail_uom , a.inventory_item_id
    FROM gmd_material_details_gtmp a , fm_matl_dtl b
    where a.entity_id = V_entity_id
    and b.formula_id = V_entity_id
    and a.inventory_item_id = b.inventory_item_id
    and b.CONTRIBUTE_YIELD_IND = 'Y'
    and a.line_type = b.line_type
    and b.line_type = 2
    UNION
    SELECT a.qty , a.detail_uom , a.inventory_item_id
    FROM gmd_material_details_gtmp a
    where a.entity_id = V_entity_id
    and a.line_type = 2
    and a.inventory_item_id NOT IN (SELECT b.inventory_item_id
                                    FROM   fm_matl_dtl b
                                    WHERE  b.formula_id = V_entity_id
                                    and b.line_type = 2);

    CURSOR Cur_get_fixed_prod_qty(V_entity_id NUMBER) IS
    SELECT b.qty , b.detail_uom , b.inventory_item_id
    FROM  fm_matl_dtl b
    WHERE b.formula_id = V_entity_id
    and b.CONTRIBUTE_YIELD_IND = 'Y'
    and b.line_type = 1
    and b.scale_type = 0;

    CURSOR Cur_get_product_percent(V_entity_id NUMBER) IS
    SELECT prod_percent , inventory_item_id , detail_uom
    FROm fm_matl_dtl
    WHERE formula_id = V_entity_id
    AND line_type = 1
    AND line_no = 1;

    CURSOR Cur_get_uom (V_entity_id NUMBER) IS
    SELECT qty , detail_uom
    FROM gmd_material_details_gtmp
    where entity_id = V_entity_id;

/* Bug No.8317833 - Changed the SELECT clause of below cursor from unit_of_measure to uom_code */
    CURSOR get_unit_of_measure(v_yield_type VARCHAR2) IS
     SELECT  uom_code
     FROM    mtl_units_of_measure
     WHERE   uom_class = v_yield_type
     AND     base_uom_flag = 'Y';

    l_org_id NUMBER;
    l_ing_qty NUMBER := 0;
    l_byprod_qty NUMBER := 0;
    l_fix_prod_qty NUMBER := 0;
    l_prod_qty NUMBER := 0;
    l_prod_percent NUMBER ;

    l_temp_qty NUMBER := 0;

    l_count NUMBER := 0;
    l_different_uom VARCHAR2(1);
    l_uom VARCHAR2(20);
   l_uom_class VARCHAR2(20);
   l_common_uom_class VARCHAR2(20);
   l_yield_type	 VARCHAR2(100);
   l_conv_uom         VARCHAR2(30);
   l_return_status VARCHAr2(100);

   CANNOT_CONVERT   EXCEPTION;

    BEGIN

    -- Get Owner Organization
     OPEN Cur_get_org_id;
     FETCH Cur_get_org_id INTO l_org_id;
     CLOSE Cur_get_org_id;
   --  Get the Yield type UOM - NPD Convergence
      GMD_API_GRP.FETCH_PARM_VALUES (	P_orgn_id       => l_org_id		,
					P_parm_name     => 'FM_YIELD_TYPE'	,
					P_parm_value    => l_yield_type		,
					X_return_status => x_return_status	);

      FOR l_rec IN Cur_get_uom(V_entity_id)
      LOOP
         l_count := l_count + 1;

         IF NVL (l_uom, l_rec.detail_uom) <> l_rec.detail_uom
         THEN
            l_different_uom := 'Y';
         END IF;
         l_uom := l_rec.detail_uom;

      -- UOM COnversions
      	IF l_rec.detail_uom IS NOT NULL THEN
	       SELECT   uom_class
          INTO l_uom_class
          FROM    mtl_units_of_measure
          where uom_code = l_rec .detail_uom;

         IF NVL(l_common_uom_class,l_uom_class) <> l_uom_class THEN
	         OPEN get_unit_of_measure(l_yield_type);
	         FETCH get_unit_of_measure INTO l_conv_uom;
	         CLOSE get_unit_of_measure;
         END IF;
         l_common_uom_class := l_uom_class;
    	END IF;
      IF l_conv_uom IS NULL THEN
	         OPEN get_unit_of_measure(l_common_uom_class);
	         FETCH get_unit_of_measure INTO l_conv_uom;
	         CLOSE get_unit_of_measure;

      END IF;

      END LOOP;

    FOR l_ing_rec IN Cur_get_ingredient_qty(V_entity_id)
    LOOP
         IF l_different_uom = 'Y'
         THEN
     l_temp_qty := INV_CONVERT.inv_um_convert(item_id         => l_ing_rec.inventory_item_id
                                         ,precision      => 5
                                         ,from_quantity  => l_ing_rec.qty
                                         ,from_unit      => l_ing_rec .detail_uom
                                         ,to_unit        => l_conv_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);

            IF l_temp_qty < 0
            THEN
               fnd_message.set_name ('GMD', 'GMD_UOM_CONV_ERROR');
	             fnd_message.set_token('UOM',l_conv_uom);
	             fnd_msg_pub.ADD;
               RAISE CANNOT_CONVERT;
               -- EXIT;
            END IF;
         ELSE
            l_temp_qty := l_ing_rec.qty;
         END IF;
         l_ing_qty := l_ing_qty + l_temp_qty;
    END LOOP;

    FOR l_byprod_rec IN Cur_get_byproduct_qty(V_entity_id)
    LOOP
         IF l_different_uom = 'Y'
         THEN
     l_temp_qty := INV_CONVERT.inv_um_convert(item_id         => l_byprod_rec.inventory_item_id
                                         ,precision      => 5
                                         ,from_quantity  => l_byprod_rec.qty
                                         ,from_unit      => l_byprod_rec .detail_uom
                                         ,to_unit        => l_conv_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);

            IF l_temp_qty < 0
            THEN
               fnd_message.set_name ('GMD', 'GMD_UOM_CONV_ERROR');
	             fnd_message.set_token('UOM',l_conv_uom);
               fnd_msg_pub.ADD;
               RAISE CANNOT_CONVERT;
               -- EXIT;
            END IF;
         ELSE
            l_temp_qty := l_byprod_rec.qty;
         END IF;
         l_byprod_qty := l_byprod_qty + l_temp_qty;
    END LOOP;

    FOR l_fixprod_rec IN Cur_get_fixed_prod_qty(V_entity_id)
    LOOP
         IF l_different_uom = 'Y'
         THEN
     l_temp_qty := INV_CONVERT.inv_um_convert(item_id         => l_fixprod_rec.inventory_item_id
                                         ,precision      => 5
                                         ,from_quantity  => l_fixprod_rec.qty
                                         ,from_unit      => l_fixprod_rec .detail_uom
                                         ,to_unit        => l_conv_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);

            IF l_temp_qty < 0
            THEN
               fnd_message.set_name ('GMD', 'GMD_UOM_CONV_ERROR');
	             fnd_message.set_token('UOM',l_conv_uom);
               fnd_msg_pub.ADD;
               RAISE CANNOT_CONVERT;
               -- EXIT;
            END IF;
         ELSE
            l_temp_qty := l_fixprod_rec.qty;
         END IF;
         l_fix_prod_qty := l_fix_prod_qty + l_temp_qty;
    END LOOP;

      l_prod_qty := l_ing_qty - l_byprod_qty - l_fix_prod_qty;

    FOR l_prod_rec IN Cur_get_product_percent(V_entity_id)
    LOOP
      IF l_ing_qty <> 0 AND l_prod_rec.prod_percent IS NOT NULL THEN
        l_prod_qty := l_prod_qty*l_prod_rec.prod_percent/100;
         IF l_different_uom = 'Y'
         THEN
            l_temp_qty := INV_CONVERT.inv_um_convert(item_id         => l_prod_rec.inventory_item_id
                                         ,precision      => 5
                                         ,from_quantity  => l_prod_qty
                                         ,from_unit      => l_conv_uom
                                         ,to_unit        => l_prod_rec.detail_uom
                                         ,from_name      => NULL
                                         ,to_name	 => NULL);

            IF l_temp_qty < 0
            THEN
               x_return_status := 'Q';
               fnd_message.set_name ('GMD', 'GMD_UOM_CONV_ERROR');
	             fnd_message.set_token('UOM',l_conv_uom);
               fnd_msg_pub.ADD;
               EXIT;
            END IF;
         ELSE
            l_temp_qty := l_prod_qty;
         END IF;
         UPDATE gmd_material_details_gtmp
        SET qty = l_temp_qty
        WHERE line_type = 1
        AND   entity_id = V_entity_id;
      END IF;
      END LOOP;

EXCEPTION
    WHEN CANNOT_CONVERT THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      /* fnd_message.set_name ('GMD', 'GMD_UNEXPECTED_ERROR');
      fnd_message.set_token ('ERROR', SQLERRM);
      fnd_msg_pub.ADD; */
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);
    END auto_calc_product;


END GMD_SPREAD_CALCULATE_PKG;

/

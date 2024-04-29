--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_ANALYSIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_ANALYSIS" AS
/* $Header: GMDFANLB.pls 120.6.12000000.2 2007/09/13 07:21:34 kannavar ship $ */

G_PKG_NAME VARCHAR2(32);

/*======================================================================
--  PROCEDURE :
--   analyze_formula
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for analyzing the
--    formula ingredient contribution.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    analyze_formula(X_orgn_code, X_lab, X_formula_id, X_analysis_qty,
--                    X_rep_um, X_explosion_rule, X_return_status,
--                    X_msg_count, X_msg_data);
--
--===================================================================== */
PROCEDURE analyze_formula(err_buf           OUT NOCOPY VARCHAR2,
                          ret_code          OUT NOCOPY VARCHAR2,
                          p_organization_id IN  NUMBER,
                          p_laboratory_id   IN  NUMBER,
                          p_formula_no      IN  VARCHAR2,
                          p_formula_vers    IN  NUMBER,
                          p_formula_id      IN  NUMBER,
                          p_analysis_qty    IN  NUMBER,
                          p_rep_um          IN  VARCHAR2,
                          p_explosion_rule  IN  NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2) IS

  -- NPD Conv.
  CURSOR Cur_std_um(V_type VARCHAR2) IS
    SELECT  uom_code
    FROM    mtl_units_of_measure
    WHERE   uom_class = V_type
    AND     base_uom_flag = 'Y';

  -- NPD Conv.
  CURSOR Cur_prods_byprods IS
    SELECT d.inventory_item_id, d.qty, d.detail_uom, i.concatenated_segments
    FROM   fm_matl_dtl d, mtl_system_items_kfv i
    WHERE  formula_id = p_formula_id
           AND line_type <> -1
           AND i.inventory_item_id = d.inventory_item_id;

  X_user         NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
  X_login_id     NUMBER := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));
  X_row          NUMBER := 0;
  X_item         VARCHAR2(32);
  l_orgn_code    VARCHAR2(4);
  X_from_um      mtl_units_of_measure.uom_code%TYPE;
  X_status       VARCHAR2(32);
  l_return_status VARCHAR2(10);
  X_rec          ing_rec;
  X_scale_factor NUMBER := 0;
  X_output_qty   NUMBER := 0;
  X_conv_qty     NUMBER := 0;
  NO_ORGN_CODE   EXCEPTION;
  NO_FORMULA     EXCEPTION;
  NO_ATTRIB_DATA EXCEPTION;
  BAD_SYS_UOM    EXCEPTION;
  LOAD_DATA_ERR  EXCEPTION;
  LOAD_INGR_ERR  EXCEPTION;
  UOM_CONV_ERR   EXCEPTION;

BEGIN
  IF (p_organization_id IS NULL) THEN
    RAISE NO_ORGN_CODE;
  END IF;
  IF (p_formula_id IS NULL) THEN
    RAISE NO_FORMULA;
  END IF;

  -- NPD Convergence

  GMD_API_GRP.FETCH_PARM_VALUES (P_orgn_id      => p_organization_id	,
				P_parm_name     => 'GMD_MASS_UM_TYPE'	,
				P_parm_value    => P_mass_um_type	,
				X_return_status => l_return_status	);

  GMD_API_GRP.FETCH_PARM_VALUES (P_orgn_id      => p_organization_id	,
				P_parm_name     => 'GMD_VOLUME_UM_TYPE'	,
				P_parm_value    => P_vol_um_type	,
				X_return_status => l_return_status	);

  /*P_mass_um_type := FND_PROFILE.VALUE('LM$UOM_MASS_TYPE');
  P_vol_um_type  := FND_PROFILE.VALUE('LM$UOM_VOLUME_TYPE');*/

  P_density      := FND_PROFILE.VALUE('LM$DENSITY');

  FND_MESSAGE.SET_NAME('FND', 'FND_MESSAGE_TYPE_ERROR');
  P_error := UPPER(FND_MESSAGE.GET)||' : ';
  FND_MESSAGE.SET_NAME('FND', 'FND_MESSAGE_TYPE_WARNING');
  P_warning := UPPER(FND_MESSAGE.GET)||' : ';

  OPEN Cur_std_um(P_mass_um_type);
  FETCH Cur_std_um INTO P_mass_um;
  IF (Cur_std_um%NOTFOUND) THEN
    CLOSE Cur_std_um;
    RAISE BAD_SYS_UOM;
  END IF;
  CLOSE Cur_std_um;

  OPEN Cur_std_um(P_vol_um_type);
  FETCH Cur_std_um INTO P_vol_um;
  IF (Cur_std_um%NOTFOUND) THEN
    CLOSE Cur_std_um;
    RAISE BAD_SYS_UOM;
  END IF;
  CLOSE Cur_std_um;

  load_ingreds(p_formula_id    => p_formula_id,
               x_ing_tab       => P_ingred_tab,
               x_return_status => X_status);
  IF (X_status <> 'S') THEN
    RAISE LOAD_INGR_ERR;
  END IF;

  FOR get_rec IN Cur_prods_byprods LOOP
    IF (get_rec.detail_uom <> p_rep_um) THEN
      -- NPD Conv.
      X_conv_qty := INV_CONVERT.inv_um_convert( item_id         => get_rec.inventory_item_id
                                                ,precision      => 5
                                                ,from_quantity  => get_rec.qty
                                                ,from_unit      => get_rec.detail_uom
                                                ,to_unit        => p_rep_um
                                                ,from_name      => NULL
                                                ,to_name        => NULL	);
      IF (X_conv_qty < 0) THEN
        X_item    := get_rec.inventory_item_id;
        X_from_um := get_rec.detail_uom;
        RAISE UOM_CONV_ERR;
      END IF;
    ELSE
      X_conv_qty := get_rec.qty;
    END IF;
    X_output_qty := X_output_qty + X_conv_qty;
  END LOOP;
  IF (X_output_qty > 0) THEN
    X_scale_factor := ROUND((p_analysis_qty / X_output_qty),4);
  ELSE
    X_scale_factor := 1;
  END IF;

  /* Scale the ingredients and get back the values */
  IF (X_scale_factor <> 1) THEN
    scale_table(p_formula_id   => p_formula_id,
                p_orgn_id      => p_organization_id,
                p_scale_factor => X_scale_factor,
                p_table        => P_ingred_tab);
  END IF;

  /* Loop through ingredients and explode where necessary and populate final table. */
  FOR i IN 1..P_ingred_tab.count LOOP
    X_rec := P_ingred_tab(i);
    P_form_tab(1).formula_id := p_formula_id;
    check_explosion(p_formula_id      => p_formula_id,
                    p_organization_id => p_organization_id,
                    p_laboratory_id   => p_laboratory_id,
                    p_explosion_rule  => p_explosion_rule,
                    p_rec             => X_rec,
                    x_return_status   => X_status);
    IF (X_status <> 'S') THEN
      RAISE LOAD_DATA_ERR;
    END IF;
    P_form_tab.delete;
  END LOOP;

  /* Calculate the percentages for weights and volumes. */
  calc_percent(p_orgn_id => p_organization_id, x_return_status => X_status);
  IF (X_status <> 'S') THEN
    RAISE LOAD_DATA_ERR;
  END IF;

  /* Remove any previous analysis data for this formula and organization */
  DELETE FROM gmd_formula_analysis_dtl
  WHERE       formula_id = p_formula_id
              AND organization_id = p_organization_id
              AND laboratory_id   = p_laboratory_id;

  DELETE FROM gmd_formula_analysis_hdr
  WHERE       formula_id = p_formula_id
              AND organization_id = p_organization_id
              AND laboratory_id   = p_laboratory_id;

  /* Insert records into tables. */
  INSERT INTO gmd_formula_analysis_hdr
             (formula_id, organization_id, laboratory_id, explosion_rule, created_by, creation_date,
              last_updated_by, last_update_date, last_update_login, analysis_qty, analysis_hdr_uom)
  VALUES     (p_formula_id,  p_organization_id, p_laboratory_id, p_explosion_rule, X_user, SYSDATE,
              X_user, SYSDATE, X_login_id, p_analysis_qty, p_rep_um);

  FOR i IN 1..P_dtl_tab.COUNT LOOP
    INSERT INTO gmd_formula_analysis_dtl
               (formula_id, organization_id, laboratory_id, inventory_item_id, technical_class, technical_sub_class,
                direct_weight, direct_weight_percent, indirect_weight, indirect_weight_percent,
                direct_volume, direct_volume_percent, indirect_volume, indirect_volume_percent)
    VALUES     (p_formula_id, p_organization_id, p_laboratory_id, P_dtl_tab(i).inventory_item_id, P_dtl_tab(i).technical_class,
                P_dtl_tab(i).technical_sub_class, ROUND(P_dtl_tab(i).direct_weight,6),
                ROUND(P_dtl_tab(i).direct_weight_percent,6), ROUND(P_dtl_tab(i).indirect_weight,6),
                ROUND(P_dtl_tab(i).indirect_weight_percent,6), ROUND(P_dtl_tab(i).direct_volume,6),
                ROUND(P_dtl_tab(i).direct_volume_percent,6), ROUND(P_dtl_tab(i).indirect_volume,6),
                ROUND(P_dtl_tab(i).indirect_volume_percent,6));
  END LOOP;
  COMMIT WORK;
EXCEPTION
  WHEN NO_ORGN_CODE THEN
    FND_MESSAGE.SET_NAME('GMI', 'IC_ORGNCODERR');
    FND_FILE.PUT(FND_FILE.LOG, P_error||FND_MESSAGE.GET);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
      NULL;
    END IF;
  WHEN NO_FORMULA THEN
    FND_MESSAGE.SET_NAME('GMD', 'QC_INVALID_FORMULA');
    FND_FILE.PUT(FND_FILE.LOG, P_error||FND_MESSAGE.GET);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
      NULL;
    END IF;
  WHEN BAD_SYS_UOM THEN
    FND_MESSAGE.SET_NAME('GMD', 'LM_BAD_SYSTEM_UOMS');
    FND_FILE.PUT(FND_FILE.LOG, P_error||FND_MESSAGE.GET);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
      NULL;
    END IF;
  WHEN LOAD_DATA_ERR THEN
    FND_FILE.PUT(FND_FILE.LOG, P_space||P_error||FND_MESSAGE.GET);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
      NULL;
    END IF;
  WHEN LOAD_INGR_ERR THEN
    FND_FILE.PUT(FND_FILE.LOG, P_space||P_error||FND_MESSAGE.GET);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
      NULL;
    END IF;
  WHEN UOM_CONV_ERR THEN
    FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item);
    FND_MESSAGE.SET_TOKEN('FROM_UOM', X_from_um);
    FND_MESSAGE.SET_TOKEN('TO_UOM', p_rep_um);
    FND_FILE.PUT(FND_FILE.LOG, P_space||P_error||FND_MESSAGE.GET);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
      NULL;
    END IF;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
    FND_FILE.PUT(FND_FILE.LOG, P_space||P_error||FND_MESSAGE.GET);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
      NULL;
    END IF;
END analyze_formula;

/*======================================================================
--  PROCEDURE :
--   calc_percent
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for calculating the
--    weight/volume percentages.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    calc_percent(X_return_status);
-- --  HISTORY
--  Kishore - Bug No.6051738 - Dt.13-09-2007
--    Added validation, not to consider the Item if qty is 0.
--===================================================================== */
PROCEDURE calc_percent(p_orgn_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
  X_tot_wt    NUMBER := 0;
  X_tot_vol   NUMBER := 0;
  X_wts       NUMBER := 0;
  X_vol       NUMBER := 0;
  X_item      VARCHAR2(32);

CURSOR Cur_get_class(V_item_id NUMBER, V_orgn_id NUMBER) IS
    SELECT mc.segment1 technical_class, mc.segment2 technical_sub_class
    FROM   mtl_category_sets mcs, mtl_default_category_sets mdc, mtl_item_categories mic,
           mtl_categories_b mc
    WHERE  mdc.functional_area_id = 16
           AND mic.inventory_item_id = V_item_id
           AND mic.organization_id   = V_orgn_id
           AND mic.category_set_id   = mdc.category_set_id
           AND mic.category_id       = mc.category_id
           AND mdc.category_set_id   = mcs.category_set_id;

  X_class       Cur_get_class%ROWTYPE;
  CURSOR Cur_get_item(V_item_id NUMBER) IS
    SELECT concatenated_segments
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = V_item_id;
  NO_TECH_CLASS    EXCEPTION;
  NO_WT_OR_VOL     EXCEPTION;

   /* Bug No. 6057138 - Start */
  X_orig_qty Number :=0;
   CURSOR Cur_get_qty(V_item_id NUMBER, V_formulaid NUMBER, V_line_no NUMBER) IS
    SELECT qty
    FROM   fm_matl_dtl
    WHERE  inventory_item_id = V_item_id and
                  line_no  = V_line_no and
		  formula_id = V_formulaid ;
  /* Bug No. 6057138 - End */

BEGIN
  x_return_status := 'S';
  /* Determine if any of items could not be converted to mass or volume */
  /* Also if some items cannot be converted to mass and some to volume stop */
  FOR i IN 1..P_dtl_tab.count LOOP
  /* Bug No. 6057138 - Start */
    OPEN Cur_get_qty(P_dtl_tab(i).inventory_item_id,P_dtl_tab(i).formula_id,P_dtl_tab(i).line_no);
     FETCH Cur_get_qty INTO X_orig_qty;
    CLOSE Cur_get_qty;
/* Bug No. 6057138 - End */
    IF ((P_dtl_tab(i).direct_weight + P_dtl_tab(i).indirect_weight) = 0) AND X_orig_qty <> 0 THEN
      X_wts := X_wts + 1;
    END IF;
    IF ((P_dtl_tab(i).direct_volume + P_dtl_tab(i).indirect_volume) = 0) AND X_orig_qty <> 0 THEN
      X_vol := X_vol + 1;
    END IF;
  END LOOP;
  IF (X_wts > 0 AND X_vol > 0) THEN
    RAISE NO_WT_OR_VOL;
  END IF;
  /* Find the total weights and volumes */
  FOR i IN 1..P_dtl_tab.count LOOP
    IF (X_wts = 0) THEN
      X_tot_wt  := X_tot_wt + P_dtl_tab(i).direct_weight + P_dtl_tab(i).indirect_weight;
    ELSE
      P_dtl_tab(i).direct_weight   := 0;
      P_dtl_tab(i).indirect_weight := 0;
    END IF;
    IF (X_vol = 0) THEN
      X_tot_vol := X_tot_vol + P_dtl_tab(i).direct_volume + P_dtl_tab(i).indirect_volume;
    ELSE
      P_dtl_tab(i).direct_volume   := 0;
      P_dtl_tab(i).indirect_volume := 0;
    END IF;
    /* Get technical class and sub class and populate */
    OPEN Cur_get_class(P_dtl_tab(i).inventory_item_id, p_orgn_id);
    FETCH Cur_get_class INTO X_class;
    IF (Cur_get_class%NOTFOUND) THEN
      CLOSE Cur_get_class;
      OPEN Cur_get_item(P_dtl_tab(i).inventory_item_id);
      FETCH Cur_get_item INTO X_item;
      CLOSE Cur_get_item;
      RAISE NO_TECH_CLASS;
    END IF;
    P_dtl_tab(i).technical_class     := X_class.technical_class;
    P_dtl_tab(i).technical_sub_class := X_class.technical_sub_class;
    CLOSE Cur_get_class;
  END LOOP;
  FOR i IN 1..P_dtl_tab.count LOOP
    IF (X_wts = 0) THEN
      P_dtl_tab(i).direct_weight_percent   := (P_dtl_tab(i).direct_weight / X_tot_wt) * 100;
      P_dtl_tab(i).indirect_weight_percent := (P_dtl_tab(i).indirect_weight / X_tot_wt) * 100;
    ELSE
      P_dtl_tab(i).direct_weight_percent   := 0;
      P_dtl_tab(i).indirect_weight_percent := 0;
    END IF;
    IF (X_vol = 0) THEN
      P_dtl_tab(i).direct_volume_percent   := (P_dtl_tab(i).direct_volume / X_tot_vol) * 100;
      P_dtl_tab(i).indirect_volume_percent := (P_dtl_tab(i).indirect_volume / X_tot_vol) * 100;
    ELSE
      P_dtl_tab(i).direct_volume_percent   := 0;
      P_dtl_tab(i).indirect_volume_percent := 0;
    END IF;
  END LOOP;
EXCEPTION
  WHEN NO_TECH_CLASS THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_NO_TECH_CLASS');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item);
  WHEN NO_WT_OR_VOL THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_NO_MASS_VOL_CONV');
  WHEN OTHERS THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
END calc_percent;

/*======================================================================
--  PROCEDURE :
--   check_explosion
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for exploding the
--    ingredients if any intermediates are found.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    check_explosion
--
--===================================================================== */
PROCEDURE check_explosion(p_formula_id NUMBER, p_organization_id NUMBER, p_laboratory_id IN NUMBER, p_rec IN OUT NOCOPY ing_rec,
                          p_explosion_rule NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
  X_vrules_tab  gmd_fetch_validity_rules.recipe_validity_tbl;
  X_vrules_tab1 gmd_fetch_validity_rules.recipe_validity_tbl;
  CURSOR Cur_product_qty(V_formula_id NUMBER, V_item_id NUMBER) IS
    SELECT qty, detail_uom
    FROM   fm_matl_dtl
    WHERE  formula_id = V_formula_id
           AND line_type = 1
           AND inventory_item_id = V_item_id;
  CURSOR Cur_get_formula(V_formula_id NUMBER) IS
    SELECT formula_no, formula_vers
    FROM   fm_form_mst
    WHERE  formula_id = V_formula_id;
  CURSOR get_orgn_code IS
    SELECT organization_code
      FROM org_access_view
     WHERE organization_id = p_organization_id;

  X_formula_id   NUMBER;
  X_formula_no   VARCHAR2(32);
  X_formula_vers NUMBER;
  X_formula_sts  VARCHAR2(10);
  X_cur_form_no  VARCHAR2(32);
  X_cur_form_ver NUMBER;
  X_expl_fm_id   NUMBER;
  X_row          NUMBER := 0;
  X_found        NUMBER := 0;
  X_prod_qty     NUMBER;
  X_conv_qty     NUMBER;
  X_scale_factor NUMBER;
  X_item_um      mtl_units_of_measure.uom_code%TYPE;
  X_status       VARCHAR2(20);
  l_orgn_code    VARCHAR2(3);
  X_rec          ing_rec;
  X_ingred_table ing_tab;
  LOAD_INGR_ERR  EXCEPTION;
  LOAD_DATA_ERR  EXCEPTION;
  UOM_CONV_ERR   EXCEPTION;

BEGIN
  x_return_status := 'S';
  IF (p_rec.iaformula_id IS NOT NULL) THEN
    X_expl_fm_id := p_rec.iaformula_id;
    OPEN Cur_get_formula(p_rec.iaformula_id);
    FETCH Cur_get_formula INTO X_formula_no, X_formula_vers;
    CLOSE Cur_get_formula;
  END IF;

  IF p_organization_id IS NOT NULL THEN
      OPEN get_orgn_code;
      FETCH get_orgn_code INTO l_orgn_code;
      CLOSE get_orgn_code;
  END IF;

  IF (X_expl_fm_id IS NULL) THEN
    /* Get all validity rules based on organization, item and quantity */
    try_validity_rules(p_item_id         => p_rec.item_id,
                       p_organization_id => p_organization_id,
                       p_qty             => p_rec.qty,
                       p_uom             => p_rec.item_um,
                       X_vr_tbl          => X_vrules_tab);
    /* Get all validity rules based on item and quantity and global */
    try_validity_rules(p_item_id         => p_rec.item_id,
                       p_organization_id => NULL,
                       p_qty             => p_rec.qty,
                       p_uom             => p_rec.item_um,
                       X_vr_tbl          => X_vrules_tab1);
    /* Populate validity rules into one single table */
    FOR i IN 1..X_vrules_tab1.count LOOP
      X_vrules_tab(X_vrules_tab.count + 1) := X_vrules_tab1(i);
    END LOOP;
    X_vrules_tab1.delete;
    /* Remove validity rules that are ON-HOLD or OBSOLETE and are of not Technical and Production Use */
    FOR i IN 1..X_vrules_tab.count LOOP
      IF (NOT(X_vrules_tab(i).recipe_use IN (0,4) AND
             ((X_vrules_tab(i).validity_rule_status BETWEEN 400 AND 499) OR
              (X_vrules_tab(i).validity_rule_status BETWEEN 700 AND 799) OR
              (X_vrules_tab(i).validity_rule_status BETWEEN 900 AND 999)))) THEN
        X_vrules_tab.delete(i);
      END IF;
    END LOOP;
    IF (X_vrules_tab.count > 0) THEN
      P_vrules_tab := X_vrules_tab;
      X_found := 0;
      /* Explosion rule on form */
      IF (p_explosion_rule = 0) THEN
        /* Use production Formulas */
        IF (p_rec.exp_ind = 1) THEN
          /* Experimental Item try to find a validity rule in Lab for technical use*/
          get_valid_formula(p_recipe_use   => 4,
                            p_vr_status    => '4,9',
                            p_status       => '4,9',
                            x_formula_id   => X_expl_fm_id,
                            x_formula_no   => X_formula_no,
                            x_formula_vers => X_formula_vers,
                            x_found        => X_found);
          IF (X_found = 0) THEN
            X_expl_fm_id := NULL;
            /* Experimental Item try to find a validity rule in Lab for production use*/
            get_valid_formula(p_recipe_use   => 0,
                              p_vr_status    => '4,9',
                              p_status       => '4,9',
                              x_formula_id   => X_expl_fm_id,
                              x_formula_no   => X_formula_no,
                              x_formula_vers => X_formula_vers,
                              x_found        => X_found);
            IF (X_found = 0) THEN
              X_expl_fm_id := NULL;
            END IF; /* Experimental Item try to find a validity rule in Lab for production use*/
          END IF; /* Experimental Item try to find a validity rule in Lab for technical use*/
        ELSE /* Experimental item check */
          /* Item is not experimental find validity rule in technical use*/
          get_valid_formula(p_recipe_use   => 4,
                            p_vr_status    => '7,9',
                            p_status       => '7,9',
                            x_formula_id   => X_expl_fm_id,
                            x_formula_no   => X_formula_no,
                            x_formula_vers => X_formula_vers,
                            x_found        => X_found);
          IF (X_found = 0) THEN
            X_expl_fm_id := NULL;
            /* No formula for Technical use try for production use */
            get_valid_formula(p_recipe_use   => 0,
                              p_vr_status    => '7,9',
                              p_status       => '7,9',
                              x_formula_id   => X_expl_fm_id,
                              x_formula_no   => X_formula_no,
                              x_formula_vers => X_formula_vers,
                              x_found        => X_found);
            IF (X_found = 0) THEN
              X_expl_fm_id := NULL;
            END IF;
          END IF;
        END IF; /* Experimental item check */
      ELSE /* Explosion rule check */
        /* Use Laboratory Formulas */
        /* Find a validity rule in lab and technical use */
        get_valid_formula(p_recipe_use   => 4,
                          p_vr_status    => '4,9',
                          p_status       => '4,7,9',
                          x_formula_id   => X_expl_fm_id,
                          x_formula_no   => X_formula_no,
                          x_formula_vers => X_formula_vers,
                          x_found        => X_found);
        IF (X_found = 0) THEN
          X_expl_fm_id := NULL;
          /* Find a validity rule in lab and production use */
          get_valid_formula(p_recipe_use   => 0,
                            p_vr_status    => '4,9',
                            p_status       => '4,7,9',
                            x_formula_id   => X_expl_fm_id,
                            x_formula_no   => X_formula_no,
                            x_formula_vers => X_formula_vers,
                            x_found        => X_found);
          IF (X_found = 0) THEN
            X_expl_fm_id := NULL;
            IF (p_rec.exp_ind <> 1) THEN
              /* Find validity rule approved for general use in technical use */
              get_valid_formula(p_recipe_use   => 4,
                                p_vr_status    => '7,9',
                                p_status       => '7,9',
                                x_formula_id   => X_expl_fm_id,
                                x_formula_no   => X_formula_no,
                                x_formula_vers => X_formula_vers,
                                x_found        => X_found);
              IF (X_found = 0) THEN
                X_expl_fm_id := NULL;
                /* Find validity rule approved for general use in production use */
                get_valid_formula(p_recipe_use   => 0,
                                  p_vr_status    => '7,9',
                                  p_status       => '7,9',
                                  x_formula_id   => X_expl_fm_id,
                                  x_formula_no   => X_formula_no,
                                  x_formula_vers => X_formula_vers,
                                  x_found        => X_found);
                IF (X_found = 0) THEN
                  X_expl_fm_id := NULL;
                END IF; /* Find validity rule approved for general use in production use */
              END IF; /* Find validity rule approved for general use in technical use */
            END IF; /* Experimental item check */
          END IF; /* Find a validity rule in lab and production use */
        END IF; /* Find a validity rule in lab and technical use */
      END IF; /* explosion rule check */
    END IF; /* No validity rules */
  END IF; /* Explosion formula check */
  X_found := 0;
  IF (X_expl_fm_id IS NOT NULL) THEN
    OPEN Cur_get_formula(p_rec.formula_id);
    FETCH Cur_get_formula INTO X_cur_form_no, X_cur_form_ver;
    CLOSE Cur_get_formula;
    /* Determine circular references */
    FOR i IN 1..P_form_tab.count LOOP
      IF (P_form_tab(i).formula_id = X_expl_fm_id) THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_CIRCULAR_REFERENCE');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', p_rec.item_no);
        FND_MESSAGE.SET_TOKEN('F1', X_cur_form_no);
        FND_MESSAGE.SET_TOKEN('V1', TO_CHAR(X_cur_form_ver));
        FND_FILE.PUT(FND_FILE.LOG, P_space||P_warning||FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
        IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', NULL)) THEN
          NULL;
        END IF;
        X_expl_fm_id := NULL;
        X_found := 1;
        EXIT;
      END IF;
    END LOOP;
    IF (X_found = 0) THEN
      P_form_tab(P_form_tab.count + 1).formula_id := p_rec.formula_id;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_EXPLOSION_FORMULA');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', p_rec.item_no);
      FND_MESSAGE.SET_TOKEN('F1', X_cur_form_no);
      FND_MESSAGE.SET_TOKEN('V1', TO_CHAR(X_cur_form_ver));
      FND_MESSAGE.SET_TOKEN('F2', X_formula_no);
      FND_MESSAGE.SET_TOKEN('V2', TO_CHAR(X_formula_vers));
      FND_FILE.PUT(FND_FILE.LOG, P_space||FND_MESSAGE.GET);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      P_space := P_space ||'  ';
    END IF;
  END IF;
  X_found := 0;
  /* Processing over for this ingredient add/update it to final table if it is not being exploded */
  IF (X_expl_fm_id IS NULL) THEN
    /* Calculate the equivalent mass and volume qtys */
    calc_mass_vol_qty(p_rec             => p_rec,
                      p_organization_id => p_organization_id,
                      p_laboratory_id   => p_laboratory_id,
                      x_return_status   => X_status);
    IF (X_status <> 'S') THEN
      RAISE LOAD_DATA_ERR;
    END IF;
    FOR j IN 1..P_dtl_tab.count LOOP
      /* Check in final table if this item exists and update direct qtys */
      IF (p_rec.item_id = P_dtl_tab(j).item_id) THEN
        IF (p_rec.formula_id = p_formula_id) THEN
          P_dtl_tab(j).direct_weight := P_dtl_tab(j).direct_weight + p_rec.mass_qty;
          P_dtl_tab(j).direct_volume := P_dtl_tab(j).direct_volume + p_rec.vol_qty;
        ELSE
          P_dtl_tab(j).indirect_weight := P_dtl_tab(j).indirect_weight + p_rec.mass_qty;
          P_dtl_tab(j).indirect_volume := P_dtl_tab(j).indirect_volume + p_rec.vol_qty;
        END IF;
        X_found := 1;
        EXIT;
      END IF;
    END LOOP;
    IF (X_found = 0) THEN
      /* Item was not found in the final table add it */
      X_row := P_dtl_tab.count + 1;
      P_dtl_tab(X_row).formula_id          := p_rec.formula_id;
      P_dtl_tab(X_row).orgn_code           := l_orgn_code;
      P_dtl_tab(X_row).organization_id     := p_organization_id;
      P_dtl_tab(X_row).inventory_item_id   := p_rec.item_id;
      P_dtl_tab(X_row).technical_class     := p_rec.technical_class;
      P_dtl_tab(X_row).technical_sub_class := p_rec.technical_sub_class;
      P_dtl_tab(X_row).line_no := p_rec.line_no; /* Added in Bug No.6057138*/
      IF (p_rec.formula_id = p_formula_id) THEN
        P_dtl_tab(X_row).direct_weight   := p_rec.mass_qty;
        P_dtl_tab(X_row).direct_volume   := p_rec.vol_qty;
        P_dtl_tab(X_row).indirect_weight := 0;
        P_dtl_tab(X_row).indirect_volume := 0;
      ELSE
        P_dtl_tab(X_row).indirect_weight := p_rec.mass_qty;
        P_dtl_tab(X_row).indirect_volume := p_rec.vol_qty;
        P_dtl_tab(X_row).direct_weight   := 0;
        P_dtl_tab(X_row).direct_volume   := 0;
      END IF;
    END IF;
  END IF;
  IF (X_expl_fm_id IS NOT NULL) THEN
    load_ingreds(p_formula_id    => X_expl_fm_id,
                 x_ing_tab       => X_ingred_table,
                 x_return_status => X_status);
    IF (X_status <> 'S') THEN
      RAISE LOAD_INGR_ERR;
    END IF;
    OPEN Cur_product_qty(X_expl_fm_id, p_rec.item_id);
    FETCH Cur_product_qty INTO X_prod_qty, X_item_um;
    CLOSE Cur_product_qty;
    IF (X_item_um <> p_rec.item_um) THEN
      --X_conv_qty := gmicuom.uom_conversion(p_rec.item_id, 0, X_prod_qty, X_item_um, p_rec.item_um, 0);
      X_conv_qty := INV_CONVERT.inv_um_convert( item_id         => p_rec.item_id
                                                ,precision      => 5
                                                ,from_quantity  => X_prod_qty
                                                ,from_unit      => X_item_um
                                                ,to_unit        => p_rec.item_um
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
      IF (X_conv_qty < 0) THEN
        RAISE UOM_CONV_ERR;
      END IF;
    ELSE
      X_conv_qty := X_prod_qty;
    END IF;
    X_scale_factor := ROUND(p_rec.qty / X_conv_qty,4);
    /* Scale the ingredients and get back the values */
    IF (X_scale_factor <> 1) THEN
      scale_table(p_formula_id   => X_expl_fm_id,
                  p_orgn_id      => p_organization_id,
                  p_scale_factor => X_scale_factor,
                  p_table        => X_ingred_table);
    END IF;

    FOR i IN 1..X_ingred_table.count LOOP
      X_rec := X_ingred_table(i);
      check_explosion(p_formula_id      => p_formula_id,
                      p_organization_id => p_organization_id,
                      p_laboratory_id   => p_laboratory_id,
                      p_explosion_rule  => p_explosion_rule,
                      p_rec             => X_rec,
                      x_return_status   => X_status);
      IF (X_status <> 'S') THEN
        RAISE LOAD_DATA_ERR;
      END IF;
    END LOOP;
    P_space := SUBSTR(P_space, 1, (LENGTH(P_space) - 2));
  END IF;
  OPEN Cur_get_formula(p_rec.formula_id);
  FETCH Cur_get_formula INTO X_cur_form_no, X_cur_form_ver;
  CLOSE Cur_get_formula;
  IF (p_rec.formula_id = p_formula_id) THEN
    P_space := NULL;
  END IF;
  FND_MESSAGE.SET_NAME('GMD', 'GMD_LAST_LEVEL');
  FND_MESSAGE.SET_TOKEN('ITEM_NO', p_rec.item_no);
  FND_MESSAGE.SET_TOKEN('F1', X_cur_form_no);
  FND_MESSAGE.SET_TOKEN('V1', X_cur_form_ver);
  FND_FILE.PUT(FND_FILE.LOG, P_space||FND_MESSAGE.GET);
  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
EXCEPTION
  WHEN LOAD_INGR_ERR THEN
    x_return_status := 'E';
  WHEN LOAD_DATA_ERR THEN
    x_return_status := 'E';
  WHEN UOM_CONV_ERR THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', p_rec.item_no);
    FND_MESSAGE.SET_TOKEN('FROM_UOM', X_item_um);
    FND_MESSAGE.SET_TOKEN('TO_UOM', p_rec.item_um);
  WHEN OTHERS THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
END check_explosion;

/*======================================================================
--  PROCEDURE :
--   get_valid_formula
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for getting the
--    formula which can be used for the explosion.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_valid_formula(X_recipe_use, X_status, X_formula_id,
--                      X_formula_no, X_formula_vers, X_found);
--
--===================================================================== */
PROCEDURE get_valid_formula(p_recipe_use NUMBER, p_vr_status VARCHAR2, p_status VARCHAR2, x_formula_id OUT NOCOPY NUMBER,
                            x_formula_no OUT NOCOPY VARCHAR2, x_formula_vers OUT NOCOPY NUMBER, x_found OUT NOCOPY NUMBER) IS
  X_formula_rec  fm_form_mst%ROWTYPE;
  X_recipe_rec   gmd_recipes%ROWTYPE;
BEGIN
  x_found := 0;
  FOR i IN 1..P_vrules_tab.count LOOP
    IF (P_vrules_tab(i).recipe_use = p_recipe_use AND INSTR(p_vr_status,SUBSTR(P_vrules_tab(i).validity_rule_status,1,1)) > 0) THEN
      get_recipe(p_recipe_id  => P_vrules_tab(i).recipe_id,
                 x_recipe_rec => X_recipe_rec);
      IF (INSTR(p_status,SUBSTR(X_recipe_rec.recipe_status,1,1)) > 0 AND X_recipe_rec.delete_mark = 0) THEN
        get_formula(p_recipe_id      => P_vrules_tab(i).recipe_id,
                    x_form_mst_rec   => X_formula_rec);
        IF (INSTR(p_status,SUBSTR(X_formula_rec.formula_status,1,1)) > 0 AND X_formula_rec.delete_mark = 0) THEN
          x_found := 1;
          x_formula_id   := X_formula_rec.formula_id;
          x_formula_no   := X_formula_rec.formula_no;
          x_formula_vers := X_formula_rec.formula_vers;
          EXIT;
        END IF;
      END IF;
    END IF;
  END LOOP;
END get_valid_formula;

/*======================================================================
--  PROCEDURE :
--   scale_table
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for scaling the
--    ingredient values to the required level.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    scale_table(X_formula_id, X_scale_factor, X_table);
--
--  HISTORY:
--    15-Sep-2004  Jeff Baird    Bug #3890191  Added X_out_tab.
--
--===================================================================== */
PROCEDURE scale_table(p_formula_id NUMBER, p_orgn_id NUMBER, p_scale_factor NUMBER, p_table IN OUT NOCOPY ing_tab) IS
  X_tab        gmd_common_scale.fm_matl_dtl_tab;
  X_out_tab    gmd_common_scale.fm_matl_dtl_tab;
-- Bug #3890191 (JKB) Added X_out_tab above.
  X_status     VARCHAR2(10);
  X_row        NUMBER := 0;

  --NPD Conv. Use inventory_item_id and detail_uom instead of item_id and item_um
  CURSOR Cur_get_lines IS
    SELECT line_no, line_type, inventory_item_id, qty, detail_uom, scale_type, contribute_yield_ind,
           scale_multiple, scale_rounding_variance
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
    ORDER BY line_type, line_no;

BEGIN
  FOR get_rec IN Cur_get_lines LOOP
    X_row := X_row + 1;
    X_tab(X_row).line_no                 := get_rec.line_no;
    X_tab(X_row).line_type               := get_rec.line_type;
    X_tab(X_row).inventory_item_id       := get_rec.inventory_item_id; --NPD Conv.
    X_tab(X_row).qty                     := get_rec.qty;
    X_tab(X_row).detail_uom              := get_rec.detail_uom;  --NPD Conv.
    X_tab(X_row).scale_type              := get_rec.scale_type;
    X_tab(X_row).contribute_yield_ind    := get_rec.contribute_yield_ind;
    X_tab(X_row).scale_multiple          := get_rec.scale_multiple;
    X_tab(X_row).scale_rounding_variance := get_rec.scale_rounding_variance;
  END LOOP;

 gmd_common_scale.scale(p_fm_matl_dtl_tab => X_tab,
                        p_orgn_id         => p_orgn_id,
                        p_scale_factor    => p_scale_factor,
                        p_primaries       => 'OUTPUTS',
                        x_fm_matl_dtl_tab => X_out_tab,
                        x_return_status   => X_status);
-- Bug #3890191 (JKB) Added X_out_tab above.
  FOR i IN 1..p_table.count LOOP
    FOR j IN 1..X_out_tab.count LOOP
      IF (X_out_tab(j).line_type = -1 AND p_table(i).line_no = X_out_tab(j).line_no) THEN
        p_table(i).qty := X_out_tab(j).qty;
-- Bug #3890191 (JKB) Added X_out_tab above.
      END IF;
    END LOOP;
  END LOOP;
END scale_table;

/*======================================================================
--  PROCEDURE :
--   try_validity_rules
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for getting the
--    validity rules depending on the parameters.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    try_validity_rules(X_item_id, X_organization_id, X_qty, X_uom, X_vr_tbl);
--
--===================================================================== */
PROCEDURE try_validity_rules(p_item_id NUMBER, p_organization_id NUMBER,
                             p_qty NUMBER, p_uom VARCHAR2,
                             X_vr_tbl OUT NOCOPY gmd_fetch_validity_rules.recipe_validity_tbl) IS
  X_status    VARCHAR2(10);
  X_msg_cnt   NUMBER;
  X_msg_dat   VARCHAR2(100);
  X_ret_code  NUMBER;
BEGIN
  gmd_fetch_validity_rules.get_validity_rules(p_api_version         => 1.0,
                                              p_init_msg_list       => 'F',
                                              p_recipe_id           => NULL,
                                              p_item_id             => p_item_id,
                                              p_organization_id     => p_organization_id,
                                              p_product_qty         => p_qty,
                                              p_uom                 => p_uom,
                                              p_recipe_use          => NULL,
                                              p_total_input         => NULL,
                                              p_total_output        => NULL,
                                              p_status              => NULL,
                                              x_return_status       => X_status,
                                              x_msg_count           => X_msg_cnt,
                                              x_msg_data            => X_msg_dat,
                                              x_return_code         => X_ret_code,
                                              X_recipe_validity_out => X_vr_tbl);
END try_validity_rules;

/*======================================================================
--  PROCEDURE :
--   load_ingreds
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for populating the
--    ingredients for a particular formula.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    load_ingreds
--
--===================================================================== */
PROCEDURE load_ingreds(p_formula_id NUMBER, x_ing_tab OUT NOCOPY ing_tab,
                       x_return_status OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_ingred_items IS
    SELECT d.inventory_item_id, d.line_no, i.concatenated_segments, d.qty, d.detail_uom,
           d.iaformula_id, i.eng_item_flag, d.formula_id, d.tpformula_id
    FROM   fm_matl_dtl d, mtl_system_items_kfv i
    WHERE  d.formula_id = p_formula_id
           AND d.line_type = -1
           AND i.inventory_item_id = d.inventory_item_id
           AND d.organization_id = i.organization_id
    ORDER BY d.line_no;
  X_item        VARCHAR2(32);
  X_conv_qty    NUMBER := 0;
  X_row         NUMBER := 0;
BEGIN
  x_return_status := 'S';
  FOR get_rec IN Cur_ingred_items LOOP
    X_row := X_row + 1;
    x_ing_tab(X_row).item_id      := get_rec.inventory_item_id;
    x_ing_tab(X_row).line_no      := get_rec.line_no;
    x_ing_tab(X_row).item_no      := get_rec.concatenated_segments;
    x_ing_tab(X_row).qty          := get_rec.qty;
    x_ing_tab(X_row).item_um      := get_rec.detail_uom;
    IF get_rec.eng_item_flag = 'Y' THEN
    x_ing_tab(X_row).exp_ind      := 1;
    ELSE
    x_ing_tab(X_row).exp_ind      := 0;
    END IF;
    x_ing_tab(X_row).iaformula_id := get_rec.iaformula_id;
    x_ing_tab(X_row).formula_id   := get_rec.formula_id;
    x_ing_tab(X_row).tpformula_id := get_rec.tpformula_id;
  END LOOP;
END load_ingreds;

/*======================================================================
--  PROCEDURE :
--   calc_mass_vol_qty
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for calculating the
--    mass and volume qtys in the table passed.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    calc_mass_vol_qty(X_rec, X_orgn_code, X_status);
--
--===================================================================== */
PROCEDURE calc_mass_vol_qty(p_rec IN OUT NOCOPY ing_rec, p_organization_id IN NUMBER,
                            p_laboratory_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR Cur_get_type(V_um_code VARCHAR2) IS
    SELECT uom_class
    FROM   mtl_units_of_measure
    WHERE  uom_code = V_um_code;

  X_conv_qty    NUMBER;
  X_density     NUMBER;
  X_item        VARCHAR2(32);
  X_status      VARCHAR2(10);
  X_from_um     mtl_units_of_measure.uom_code%TYPE;
  X_to_um       mtl_units_of_measure.uom_code%TYPE;
  X_um_type     mtl_units_of_measure.uom_class%TYPE;
  UOM_CONV_ERR  EXCEPTION;
  BAD_UOM_TYPE  EXCEPTION;

BEGIN
  x_return_status := 'S';

  OPEN Cur_get_type(p_rec.item_um);
  FETCH Cur_get_type INTO X_um_type;
  CLOSE Cur_get_type;

  get_density(p_rec, p_organization_id, p_laboratory_id, P_density, X_density, X_status);
  IF (X_status = 'W') THEN
    FND_FILE.PUT(FND_FILE.LOG, P_space||P_warning||FND_MESSAGE.GET);
    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', NULL)) THEN
      NULL;
    END IF;
  ELSIF (X_status <> 'S') THEN
    x_return_status := 'E';
    RETURN;
  END IF;
  IF (X_um_type = P_mass_um_type) THEN
    /* Calculate qty in terms of mass UM */
    IF (p_rec.item_um <> P_mass_um) THEN
      -- X_conv_qty := gmicuom.uom_conversion(p_rec.item_id, 0, p_rec.qty, p_rec.item_um, P_mass_um, 0);
      X_conv_qty := INV_CONVERT.inv_um_convert(  item_id        => p_rec.item_id
                                                ,precision      => 5
                                                ,from_quantity  => p_rec.qty
                                                ,from_unit      => p_rec.item_um
                                                ,to_unit        => P_mass_um
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
      IF (X_conv_qty < 0) THEN
        X_item    := p_rec.item_no;
        X_from_um := p_rec.item_um;
        X_to_um   := P_mass_um;
        RAISE UOM_CONV_ERR;
      END IF;
    ELSE
      X_conv_qty := p_rec.qty;
    END IF;
    p_rec.mass_qty := X_conv_qty;
    IF (NVL(X_density,0) = 0) THEN
      -- X_conv_qty := gmicuom.uom_conversion(p_rec.item_id, 0, p_rec.mass_qty, P_mass_um, P_vol_um, 0);
      X_conv_qty := INV_CONVERT.inv_um_convert(  item_id        => p_rec.item_id
                                                ,precision      => 5
                                                ,from_quantity  => p_rec.mass_qty
                                                ,from_unit      => P_mass_um
                                                ,to_unit        => P_vol_um
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
      IF (X_conv_qty < 0) THEN
        FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', p_rec.item_no);
        FND_MESSAGE.SET_TOKEN('FROM_UOM', P_mass_um);
        FND_MESSAGE.SET_TOKEN('TO_UOM', P_vol_um);
        FND_FILE.PUT(FND_FILE.LOG, P_space||P_warning||FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
        IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', NULL)) THEN
          NULL;
        END IF;
        p_rec.vol_qty := 0;
      ELSE
        p_rec.vol_qty := X_conv_qty;
      END IF;
    ELSE
      p_rec.vol_qty  := X_conv_qty / X_density;
    END IF;
  ELSIF (X_um_type = P_vol_um_type) THEN
    /* Calculate qty in terms of volume UM */
    IF (p_rec.item_um <> P_vol_um) THEN
      -- X_conv_qty := gmicuom.uom_conversion(p_rec.item_id, 0, p_rec.qty, p_rec.item_um, P_vol_um, 0);
      X_conv_qty := INV_CONVERT.inv_um_convert(  item_id        => p_rec.item_id
                                                ,precision      => 5
                                                ,from_quantity  => p_rec.qty
                                                ,from_unit      => p_rec.item_um
                                                ,to_unit        => P_vol_um
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
      IF (X_conv_qty < 0) THEN
        X_item    := p_rec.item_no;
        X_from_um := p_rec.item_um;
        X_to_um   := P_vol_um;
        RAISE UOM_CONV_ERR;
      END IF;
    ELSE
      X_conv_qty := p_rec.qty;
    END IF;
    p_rec.vol_qty  := X_conv_qty;
    IF (NVL(X_density,0) = 0) THEN
      -- X_conv_qty := gmicuom.uom_conversion(p_rec.item_id, 0, p_rec.vol_qty, P_vol_um, P_mass_um, 0);
      X_conv_qty := INV_CONVERT.inv_um_convert(  item_id        => p_rec.item_id
                                                ,precision      => 5
                                                ,from_quantity  => p_rec.vol_qty
                                                ,from_unit      => P_vol_um
                                                ,to_unit        => P_mass_um
                                                ,from_name      => NULL
                                                ,to_name	=> NULL);
      IF (X_conv_qty < 0) THEN

        FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', p_rec.item_no);
        FND_MESSAGE.SET_TOKEN('FROM_UOM', P_vol_um);
        FND_MESSAGE.SET_TOKEN('TO_UOM', P_mass_um);
        FND_FILE.PUT(FND_FILE.LOG, P_space||P_warning||FND_MESSAGE.GET);
        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
        IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', NULL)) THEN
          NULL;
        END IF;
        p_rec.mass_qty := 0;
      ELSE
        p_rec.mass_qty := X_conv_qty;
      END IF;
    ELSE
      p_rec.mass_qty := X_conv_qty * X_density;
    END IF;
  ELSE
    X_item    := p_rec.item_no;
    X_from_um := p_rec.item_um;
    RAISE BAD_UOM_TYPE;
  END IF;
EXCEPTION
  WHEN UOM_CONV_ERR THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMI', 'IC_API_UOM_CONVERSION_ERROR');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item);
    FND_MESSAGE.SET_TOKEN('FROM_UOM', X_from_um);
    FND_MESSAGE.SET_TOKEN('TO_UOM', X_to_um);
  WHEN BAD_UOM_TYPE THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_NON_MASS_VOL');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item);
    FND_MESSAGE.SET_TOKEN('UM', X_from_um);
  WHEN OTHERS THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
END calc_mass_vol_qty;

/*======================================================================
--  PROCEDURE :
--   get_formula
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for getting the
--    formula for the recipe passed.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_formula(X_recipe_id, X_formula_id, X_formula_status,
--                X_formula_no, X_formula_vers);
--
--===================================================================== */
PROCEDURE get_formula(p_recipe_id IN NUMBER, x_form_mst_rec OUT NOCOPY fm_form_mst%ROWTYPE) IS
  CURSOR Cur_get_formula IS
    SELECT *
    FROM   fm_form_mst
    WHERE  formula_id = (SELECT formula_id
                         FROM   gmd_recipes
                         WHERE  recipe_id = p_recipe_id);
BEGIN
  OPEN Cur_get_formula;
  FETCH Cur_get_formula INTO x_form_mst_rec;
  CLOSE Cur_get_formula;
END get_formula;

/*======================================================================
--  PROCEDURE :
--   get_recipe
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for getting the
--    the recipe details.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_recipe(X_recipe_id, X_recipe_status,
--               X_recipe_no, X_recipe_vers);
--
--===================================================================== */
PROCEDURE get_recipe(p_recipe_id IN NUMBER, x_recipe_rec OUT NOCOPY gmd_recipes%ROWTYPE) IS
  CURSOR Cur_get_recipe IS
    SELECT *
    FROM   gmd_recipes
    WHERE  recipe_id = p_recipe_id;
BEGIN
  OPEN Cur_get_recipe;
  FETCH Cur_get_recipe INTO x_recipe_rec;
  CLOSE Cur_get_recipe;
END get_recipe;

/*======================================================================
--  PROCEDURE :
--   get_density
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for getting the
--    density value for the item and formula.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_density(X_ing_rec, X_orgn_code, X_tech_parm_name,
--                X_value, X_status);
--
--===================================================================== */
PROCEDURE get_density(p_ing_rec ing_rec, p_organization_id NUMBER, p_laboratory_id NUMBER, p_tech_parm_name VARCHAR2,
                      x_value OUT NOCOPY NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
  X_temp      NUMBER;
  X_orgn_id   NUMBER;
  l_orgn_code VARCHAR2(3);

  CURSOR Cur_check_orgn IS
    SELECT 1
    FROM   org_access_view o, gmd_parameters_hdr p
    WHERE  o.organization_id = p_organization_id
           AND o.organization_id = p.organization_id
           AND p.lab_ind = 1;

  CURSOR Cur_formula_value(vOrgn_id NUMBER) IS
    SELECT num_data
    FROM   lm_item_dat
    WHERE  organization_id = vOrgn_id
           AND tech_parm_name = p_tech_parm_name
           AND formula_id = p_ing_rec.tpformula_id
           AND inventory_item_id = p_ing_rec.item_id;
  CURSOR Cur_item_value(vOrgn_id NUMBER) IS
    SELECT num_data
    FROM   lm_item_dat
    WHERE  organization_id = vOrgn_id
           AND tech_parm_name = p_tech_parm_name
           AND inventory_item_id = p_ing_rec.item_id;

  CURSOR get_orgn_code IS
    SELECT organization_code
      FROM org_access_view
     WHERE organization_id = p_organization_id;
  BAD_DENSITY   EXCEPTION;
BEGIN
  x_return_status := 'S';

  /* Determine if organization is a lab. If not get the default lab type for the user */
  OPEN Cur_check_orgn;
  FETCH Cur_check_orgn INTO X_temp;
  IF (Cur_check_orgn%NOTFOUND) THEN
    X_orgn_id := p_laboratory_id;          -- FND_PROFILE.VALUE('GEMMS_DEFAULT_LAB_TYPE');
  ELSE
    X_orgn_id := p_organization_id;
  END IF;
  CLOSE Cur_check_orgn;

  /* Try to get the value using tpformula_id */
  OPEN Cur_formula_value(X_orgn_id);
  FETCH Cur_formula_value INTO x_value;
  IF (Cur_formula_value%NOTFOUND) THEN
    -- Try to get the value based on lab and item
    OPEN Cur_item_value(X_orgn_id);
    FETCH Cur_item_value INTO x_value;
    IF (Cur_item_value%NOTFOUND) THEN
      CLOSE Cur_item_value;
      CLOSE Cur_formula_value;
      RAISE BAD_DENSITY;
    END IF;
  END IF;
  CLOSE Cur_item_value;
  CLOSE Cur_formula_value;
  EXCEPTION
    WHEN BAD_DENSITY THEN
      OPEN get_orgn_code;
      FETCH get_orgn_code INTO l_orgn_code;
      CLOSE get_orgn_code;
      x_return_status := 'W';
      FND_MESSAGE.SET_NAME('GMD', 'GMD_NO_DENSITY');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', p_ing_rec.item_no);
      FND_MESSAGE.SET_TOKEN('ORGN', l_orgn_code);
END get_density;

END gmd_formula_analysis;

/
